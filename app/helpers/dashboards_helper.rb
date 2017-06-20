module DashboardsHelper
  def top_ten_comments
    Comment.parent_comments.order('created_at DESC').limit(10)
  end
end
