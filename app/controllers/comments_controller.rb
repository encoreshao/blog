# frozen_string_literal: true

class CommentsController < ApplicationController
  layout "articles"

  def index
    comments_cache_key = ["icmoc", "comments", Comment.maximum(:updated_at).to_s(:db)].join("/")

    @comments = Rails.cache.fetch(comments_cache_key, expires_in: 10.hours) do
      Comment.messages.sorting
    end
    @comment = Comment.new
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.save
    redirect_to action: :index
  end

  private
  def comment_params
    params[:comment][:remote_ip] = request.remote_ip
    params[:comment].delete_if { |_k, v| v.blank? }

    params.fetch(:comment, {}).permit(:name, :email, :link, :content, :remote_ip)
  end
end
