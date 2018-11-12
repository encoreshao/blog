# frozen_string_literal: true

# == Schema Information
#
# Table name: site_groups
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class SiteGroup < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :site_links

  scope :with_keywords, ->(keyword) {
    return nil if keyword.blank?

    criteria = ActiveRecord::Base.send(:sanitize_sql, keyword)
    where("LOWER(name) ILIKE LOWER(?)", "%#{criteria}%")
  }
end
