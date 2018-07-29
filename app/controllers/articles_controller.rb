# frozen_string_literal: true

class ArticlesController < ApplicationController
  layout 'articles'

  before_action :verify?, only: %i[show comment like dislike]
  before_action :cleaning_cache!, only: %i[comment like dislike]

  caches_action :show, cache_path: proc { "views/articles-#{params[:id]}" }, expires_in: 1.days

  def show
    @article.increment!(:view_count)
  end

  def comment
    @article.comments.create(comment_params)
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
      @article = Article.preload([:comments]).find_by(permalink: params[:permalink], published_at: "#{params[:year]}-#{params[:month]}-#{params[:day]}")

      redirect_to "/404" if @article.blank?
    end

    def comment_params
      params_comment = {
        content: params[:comment][:content],
        name: params[:comment][:name],
        link: params[:comment][:link],
        email: params[:comment][:email],
        comment_parent: params[:comment][:comment_parent].to_i,
        comment_id: params[:comment_id].blank? ? nil : params[:comment_id],
        remote_ip: request.remote_ip
      }

      params_comment.delete_if { |_k, v| v.blank? }
    end

    def cleaning_cache!
      WarmCaches::ActionCachingHelper.clean_article!(params[:id])
    end
end
