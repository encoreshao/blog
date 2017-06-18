module DashboardsHelper
  def top_ten_comments
    Comment.order('created_at DESC').limit(10)
  end
end
