# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    scope :fuzzy_search, ->(keyword) {
      return nil if keyword.blank?

      criteria = ActiveRecord::Base.send(:sanitize_sql, keyword)
      where("LOWER(name) ILIKE LOWER(?)", "%#{criteria}%")
    }
  end
end
