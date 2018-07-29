# frozen_string_literal: true

module WarmCaches
  class ActionCachingHelper
    class << self
      def clean_article!(article_id)
        Rails.cache.delete("views/articles-#{article_id}")
      end
    end
  end
end
