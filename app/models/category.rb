class Category < ApplicationRecord
	has_many :articles
	
  scope :with_keywords, ->(keyword) {
  	return nil if keyword.blank?

  	criteria = ActiveRecord::Base.send(:sanitize_sql, keyword)
  	where("LOWER(name_zh) ILIKE LOWER(?) OR LOWER(name_en) ILIKE LOWER(?)", "%#{criteria}%", "%#{criteria}%")
  }
end

# == Schema Information
#
# Table name: categories
#
#  id             :integer          not null, primary key
#  name_zh        :string
#  name_en        :string
#  permalink      :string
#  articles_count :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
