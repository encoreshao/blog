# frozen_string_literal: true

module DashboardsHelper
  def recently_replied_to_the_articles
    Rails.cache.fetch("icmoc_recently_replied_to_the_articles", expires_in: 1.hour) do
      article_ids = Comment.parent_comments.order("created_at DESC").limit(10).map(&:commentable_id)

      Article.select("title, created_at, published_at, permalink").where(id: article_ids)
    end
  end

  def animation?
    controller_name == "dashboards" &&
      params[:q].blank? && params[:category].blank? && params[:tag].blank? &&
      params[:page].blank?
  end
end
