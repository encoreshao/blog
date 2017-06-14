require 'rails_helper'

RSpec.describe UserProfile, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
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
