module DashboardsHelper
  def top_ten_articles_with_top_comments
    article_ids = Comment.parent_comments.group("commentable_id").order("COUNT(*) DESC").count.keys.first(10)

    Article.select('title, created_at, published_at, permalink').where(id: article_ids)
  end
end
