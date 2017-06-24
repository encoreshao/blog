class Tag < ApplicationRecord
  validates :name, :permalink, presence: true, uniqueness: true

  has_and_belongs_to_many :tags

  scope :with_keywords, ->(keyword) {
    return nil if keyword.blank?

    criteria = ActiveRecord::Base.send(:sanitize_sql, keyword)
    where("LOWER(name) ILIKE LOWER(?)", "%#{criteria}%")
  }
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
