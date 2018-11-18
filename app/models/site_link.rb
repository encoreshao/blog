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
  include AttrMethodSuffix
  include Searchable

  validates :name, :url, presence: true, uniqueness: true

  delegate :name, to: :site_group, prefix: true, allow_nil: true
  belongs_to :site_group, optional: true

  scope :enabled, -> { where(enabled: true) }
  scope :sorting, -> { order("created_at ASC") }

  after_save :cache_clear!

  class << self
    def availables
      Rails.cache.fetch("site_links_availables", expires_in: 1.hour) do
        enabled.sorting.map { |e| [e.name, e.url] }
      end
    end
  end

  private

    def cache_clear!
      Rails.cache.delete("site_links_availables")
    end
end
