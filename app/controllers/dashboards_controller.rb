class DashboardsController < ApplicationController
  def index
    @articles = Article.published.with_categories(category_id).
                with_tags(tag_id).
                with_keywords(params[:q]).
                order("published_at DESC").page(params[:page])
  end

  protected
  def category_id
    return nil if params[:category].blank?

    Category.find_by(permalink: params[:category]).try(:id)
  end

  def tag_id
    return nil if params[:tag].blank?

    nil
  end
end
