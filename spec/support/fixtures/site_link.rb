# frozen_string_literal: true

SiteLink.blueprint do
  name { "Site #{sn}" }
  email { nil }
  url { "https://url#{sn}.com" }
  enabled { false }
  site_group
end
