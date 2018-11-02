# frozen_string_literal: true

class ArticlesController < ApplicationController
  layout 'articles'

  before_action :verify?, only: %i[show comment like dislike]

  def show
    @article.increment!(:view_count)
    fresh_when(etag: @article, last_modified: @article.updated_at)
  end

  def comment
    @article.comments.create(comment_params)
    @article.update_attribute(:updated_at, Time.zone.now)

    redirect_to article_path(@article.params)
  end

  def like
    @article.increment!(:likes_count)

    render json: {
      status: 200,
      count: @article.likes_count
    }
  end

  def dislike
    @article.increment!(:dislike_count)

    render json: {
      status: 200,
      count: @article.dislike_count
    }
  end

  private
    def verify?
      @article = Article.preload([:comments, :tags]).
        find_by(permalink: params[:permalink], published_at: published_date)

      redirect_to "/404" if @article.blank?
    end

    def comment_params
      params[:comment][:comment_id] = params[:comment_id].blank? ? nil : params[:comment_id]
      params[:comment][:remote_ip] = request.remote_ip
      params[:comment].delete_if { |_k, v| v.blank? }

      params.require(:comment).permit(:comment_id, :remote_ip, :content, :name, :email, :link, :comment_parent)
    end

    def published_date
      "#{params[:year]}-#{params[:month]}-#{params[:day]}"
    end
end
