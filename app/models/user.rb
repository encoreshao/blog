class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable :recoverable, :registerable
  devise :database_authenticatable, :rememberable, :trackable, :validatable, :confirmable

  has_many :comments

  mount_uploader :avatar, AvatarUploader

  def self.active_users
    select('name, id').map { |e| [e.name, e.id] }
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
#
