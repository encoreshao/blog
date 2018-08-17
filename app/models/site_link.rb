# frozen_string_literal: true

class SiteLink < ApplicationRecord
  validates :name, :url, presence: true, uniqueness: true

  delegate :name, to: :site_group, prefix: true, allow_nil: true
  belongs_to :site_group

  scope :with_keywords, ->(keyword) {
    return nil if keyword.blank?

    criteria = ActiveRecord::Base.send(:sanitize_sql, keyword)
    where("LOWER(name) ILIKE LOWER(?)", "%#{criteria}%")
  }

  after_save :clearing_cache

  class << self
    def availables
      Rails.cache.fetch("site_links_availables", expires_in: 1.hour) do
        order("created_at ASC").map { |e| [e.name, e.url] }
      end
    end
  end

  private
    def clearing_cache
      Rails.cache.delete("site_links_availables")
    end
end
