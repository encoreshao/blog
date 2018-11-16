# frozen_string_literal: true

# == Schema Information
#
# Table name: site_links
#
#  id            :bigint(8)        not null, primary key
#  email         :string
#  enabled       :boolean          default(FALSE)
#  name          :string
#  url           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  site_group_id :bigint(8)
#
# Indexes
#
#  index_site_links_on_site_group_id  (site_group_id)
#

class SiteLink < ApplicationRecord
  validates :name, :url, presence: true, uniqueness: true
  attribute_method_suffix "_text"

  delegate :name, to: :site_group, prefix: true, allow_nil: true
  belongs_to :site_group, optional: true

  scope :enabled, -> { where(enabled: true) }
  scope :with_keywords, ->(keyword) {
    return nil if keyword.blank?

    where("LOWER(name) ILIKE LOWER(?)", "%#{sanitize_sql(keyword)}%")
  }
  scope :sorting, -> { order("created_at ASC") }

  after_save :clearing_cache

  class << self
    def availables
      Rails.cache.fetch("site_links_availables", expires_in: 1.hour) do
        enabled.sorting.map { |e| [e.name, e.url] }
      end
    end
  end

  private
    def attribute_text(attr_name)
      return unless [true, false].include?(send(attr_name))

      send(attr_name) ? "YES" : "NO"
    end

    def clearing_cache
      Rails.cache.delete("site_links_availables")
    end
end
