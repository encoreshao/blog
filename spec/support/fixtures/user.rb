# frozen_string_literal: true

User.blueprint do
  email         { "user#{sn}@blog.com" }
  name          { "User-#{sn}" }
  password      { "password" }
  confirmed_at  { Time.now }
  is_admin      { false }
end

User.blueprint(:info) do
  email         { "info#{sn}@blog.com" }
  name          { "Info-#{sn}" }
  password      { "password" }
  confirmed_at  { Time.now }
  is_admin      { false }
end

User.blueprint(:admin) do
  email         { "admin#{sn}@blog.com" }
  name          { "Admin-#{sn}" }
  password      { "password" }
  confirmed_at  { Time.now }
  is_admin      { true }
end
