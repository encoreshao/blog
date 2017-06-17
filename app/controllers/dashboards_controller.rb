class DashboardsController < ApplicationController
  before_action :verify?, only: [:show, :comment]

  def index
    @articles = Article.published.with_categories(category_id).
                with_tags(tag_id).
                with_keywords(params[:q]).
                order("published_at DESC").page(params[:page])
  end

  def show
    @article.update_column(:last_reviewed_at, Time.zone.now)
  end

  def comment
    comment_params = { content: params[:comment] }
    @article.comments.create(comment_params)

    redirect_to article_path(@article.params)
  end

  protected
  def verify?
    @article = Article.find_by(permalink: params[:permalink], published_at: "#{params[:year]}-#{params[:month]}-#{params[:day]}")

    redirect_to root_path if @article.blank?
  end

  def category_id
    return nil if params[:category].blank?

    Category.find_by(permalink: params[:category]).try(:id)
  end

  def tag_id
    return nil if params[:tag].blank?

    nil
  end
end
