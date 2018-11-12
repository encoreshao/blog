# frozen_string_literal: true

RSpec.describe User do
  let (:user) { User.make!(:info) }
  let (:admin) { User.make!(:admin) }

  it "Should be return false when user is member" do
    expect(user.member?).to be_truthy
  end

  it "Should be return false when user is member" do
    expect(user.admin?).to be_falsey
  end

  it "Should be return false when user is admin" do
    expect(admin.member?).to be_falsey
  end

  it "Should be return true when user is admin" do
    expect(admin.admin?).to be_truthy
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
#  avatar                 :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  introduction           :text
#  is_admin               :boolean          default(FALSE)
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  link                   :string
#  name                   :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  title                  :string
#  unconfirmed_email      :string
#  uuid                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
