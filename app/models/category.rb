# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :articles

  scope :fuzzy_search, ->(keyword) {
    return nil if keyword.blank?

    criteria = ActiveRecord::Base.send(:sanitize_sql, keyword)
    where("LOWER(name_zh) ILIKE LOWER(?) OR LOWER(name_en) ILIKE LOWER(?)", "%#{criteria}%", "%#{criteria}%")
  }

  def embed?
    audio? || video?
  end

  def audio?
    (permalink == "audio")
  end

  def video?
    (permalink == "video")
  end
end

# == Schema Information
#
# Table name: categories
#
#  id             :bigint(8)        not null, primary key
#  articles_count :integer          default(0)
#  name_en        :string
#  name_zh        :string
#  permalink      :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
