# frozen_string_literal: true

class DashboardsController < ApplicationController
  layout 'articles'

  def index
    @articles = loading_articles

    fresh_when(etag: @articles, last_modified: @articles.maximum(:updated_at)) unless Rails.env.development?
  end

  def articles
    @articles = loading_articles

    render partial: 'results', locals: { articles: @articles }
  end

  def loading_articles
    Article.preload(%i[category user comments tags])
           .published.with_categories(category_id)
           .with_tags(tag_id)
           .fuzzy_search(params[:q])
           .sorting
           .page(params[:page]).per(10)
  end

  protected

    def category_id
      return nil if params[:category].blank?

      Category.find_by(permalink: params[:category]).try(:id) || ""
    end

    def tag_id
      return nil if params[:tag].blank?

      Tag.find_by(permalink: params[:tag]).try(:id) || ""
    end
end
