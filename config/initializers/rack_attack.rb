# frozen_string_literal: true

class Rack::Attack::Request < ::Rack::Request
  def localhost?
    ip == "127.0.0.1"
  end
end

Rack::Attack.safelist("localhost") { |req| req.localhost? }

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

Rack::Attack.blacklist("block <ip>") do |req|
  # if variable `block <ip>` exists in cache store, then we'll block the request
  Rails.cache.fetch("block #{req.ip}").blank?
end

Rack::Attack.throttle("requests by ip", limit: 5, period: 2) do |req|
  req.ip && req.post?
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
