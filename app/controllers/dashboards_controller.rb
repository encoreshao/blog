class DashboardsController < ApplicationController
  def index
    @articles = Article.published
  end

  def show
    @article = Article.find_by(permalink: params[:permalink], published_at: "#{params[:year]}-#{params[:month]}-#{params[:day]}")
    @article.update_column(:last_reviewed_at, Time.now)
  end
end
