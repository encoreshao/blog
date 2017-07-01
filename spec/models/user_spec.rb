RSpec.describe User do
  let (:user) { User.make!(:info) }
  let (:admin) { User.make!(:admin) }

  it 'Should be return false when user is member' do
    expect(user.member?).to be_truthy
  end

  it 'Should be return false when user is member' do
    expect(user.admin?).to be_falsey
  end

  it 'Should be return false when user is admin' do
    expect(admin.member?).to be_falsey
  end

  it 'Should be return true when user is admin' do
    expect(admin.admin?).to be_truthy
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  name                   :string
#  is_admin               :boolean          default(FALSE)
#  avatar                 :string
#  link                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  title                  :string
#
