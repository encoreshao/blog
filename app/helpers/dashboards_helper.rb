# frozen_string_literal: true

module DashboardsHelper
  def top_ten_articles_with_top_comments
    Rails.cache.fetch("icmoc_top_ten_articles_with_top_comments", expires_in: 1.hour) do
      article_ids = Comment.select("commentable_id, COUNT(commentable_id) AS commentable_id_count").parent_comments.
                    group("commentable_id").order("commentable_id_count DESC").
                    limit(10).map(&:commentable_id)

      Article.select("title, created_at, published_at, permalink").where(id: article_ids)
    end
  end

  def animation?
    controller_name == "dashboards" &&
      params[:q].blank? && params[:category].blank? && params[:tag].blank? &&
      params[:page].blank?
  end
end
