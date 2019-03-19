# frozen_string_literal: true

class CommentsController < ApplicationController
  layout "articles"

  def index
    @comments = Comment.messages.sorting
    @comment = Comment.new
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.save
    redirect_to action: :index
  end

  private
    def comment_params
      params.fetch(:comment, {}).permit(:name, :email, :link, :content)
    end
end
