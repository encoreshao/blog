class Tag < ApplicationRecord
  validates :name, :permalink, presence: true, uniqueness: true

  has_and_belongs_to_many :tags
end

# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string
#  permalink  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
