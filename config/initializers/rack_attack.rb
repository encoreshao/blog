# frozen_string_literal: true

# class Rack::Attack::Request < ::Rack::Request
#   def localhost?
#     ip == "127.0.0.1"
#   end
# end

# Rack::Attack.safelist("localhost") { |req| req.localhost? }

class Rack::Attack
  class Request < ::Rack::Request
    def allowed_ip?
      allowed_ips = ["127.0.0.1", "::1"]
      allowed_ips.include?(remote_ip)
    end

    def remote_ip
      # Cloudflare stores remote IP in CF_CONNECTING_IP header
      @remote_ip ||= (env["HTTP_CF_CONNECTING_IP"] ||
                      env["action_dispatch.remote_ip"] ||
                      ip).to_s
    end
  end

  def blockips
    [
      '62.210.180.122', '62.210.202.176', '62.210.82.122', '62.210.202.55', '62.210.202.48',
      '195.154.170.190', '195.154.170.194', '195.154.187.245', '195.154.181.60', '195.154.187.229',
      '5.188.210.60', '5.188.210.35', '5.188.210.29', '5.188.210.54', '5.188.210.13'
    ]
  end

  blocklist("blockips") do |req|
    # Requests are blocked if the return value is truthy
    blockips.include?(req.ip)
  end

  safelist("allow from localhost") do |req|
    req.allowed_ip?
  end

  # https://github.com/kickstarter/rack-attack/wiki/Example-Configuration
  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle("req/ip", limit: 5, period: 2) do |req|
    req.ip
  end

  ### Prevent Brute-Force comments Attacks ###

  # Throttle POST requests to /articles/comment by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:comments/ip:#{req.ip}"
  throttle("comments/ip", limit: 5, period: 10.minutes) do |req|
    if req.path == "/articles/comments" && req.post?
      req.ip
    end
  end

  # Throttle POST requests to /login by email param
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that's not very common and shouldn't happen to you. (Knock
  # on wood!)
  throttle("logins/email", limit: 5, period: 20.seconds) do |req|
    if req.path == "/i/admin/login" && req.post?
      # return the email if present, nil otherwise
      req.params["email"].presence
    end
  end
end

# Block suspicious requests for '/etc/password' or wordpress specific paths.
# After 3 blocked requests in 10 minutes, block all requests from that IP for 5 minutes.
Rack::Attack.blocklist("fail2ban pentesters") do |req|
  # `filter` returns truthy value if request fails, or if it's from a previously banned IP
  # so the request is blocked
  Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 5.minutes) do
    # The count for the IP is incremented if the return value is truthy
    CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
    req.path.include?("/etc/passwd") ||
    req.path.include?("wp-admin") ||
    req.path.include?("wp-login")
  end
end

ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, req|
  if req.env["rack.attack.match_type"] == :throttle
    request_headers = { "CF-RAY" => req.env["HTTP_CF_RAY"],
                        "X-Amzn-Trace-Id" => req.env["HTTP_X_AMZN_TRACE_ID"] }

    Rails.logger.info "[Rack::Attack][Blocked]" <<
                      "remote_ip: \"#{req.remote_ip}\"," <<
                      "path: \"#{req.path}\", " <<
                      "headers: #{request_headers.inspect}"
  end
end

# Customizing responses
Rack::Attack.blocklisted_response = lambda do |env|
  # Using 503 because it may make attacker think that they have successfully
  # DOSed the site. Rack::Attack returns 403 for blocklists by default
  [ 503, {}, ["Blocked"]]
end


Rack::Attack.throttled_response = lambda do |env|
  match_data = env["rack.attack.match_data"]
  now = match_data[:epoch_time]

  headers = {
    "RateLimit-Limit" => match_data[:limit].to_s,
    "RateLimit-Remaining" => "0",
    "RateLimit-Reset" => (now + (match_data[:period] - now % match_data[:period])).to_s
  }

  [ 429, headers, ["Throttled\n"]]
end
