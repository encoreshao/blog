# frozen_string_literal: true

class CommentsController < ApplicationController
  def create
    @commentable = find_commentable
    @comment = @commentable.comments.build(params[:comment])
    if @comment.save
      flash[:notice] = "Successfully created comment."
      redirect_to id: nil
    else
      render action: "new"
    end
  end

  private

    def find_commentable
      params.each do |name, value|
        return Regexp.last_match(1).classify.constantize.find(value) if name =~ /(.+)_id$/
      end
      nil
    end
end
