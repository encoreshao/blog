class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  # has_many :article_tags
  # has_many :articles, through: :article_tags
  has_and_belongs_to_many :tags
end

# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
