# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable :recoverable, :registerable
  devise :database_authenticatable, :rememberable, :trackable, :validatable, :confirmable

  has_many :comments
  has_many :articles

  mount_uploader :avatar, AvatarUploader

  scope :with_keywords, ->(keyword) {
    return nil if keyword.blank?

    criteria = ActiveRecord::Base.send(:sanitize_sql, keyword)
    where("LOWER(name) ILIKE LOWER(?)", "%#{criteria}%")
  }

  before_create :setup_info!

  def self.active_users
    select("name, id").map { |e| [e.name, e.id] }
  end

  def display_name
    return name unless name.blank?

    email
  end

  def admin?
    !member?
  end

  def member?
    !is_admin?
  end

  def setup_info!
    self.uuid = SecureRandom.uuid.split("-").join
  end

  private

    def confirmation_required?
      false
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
