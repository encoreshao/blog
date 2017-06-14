class UserProfile < ApplicationRecord
  belongs_to :user
	mount_uploader :avatar, AvatarUploader
end

# == Schema Information
#
# Table name: user_profiles
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :string
#  avatar     :string
#  link       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
