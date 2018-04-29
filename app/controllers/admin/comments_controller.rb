# frozen_string_literal: true

class Admin::CommentsController < AdminController
  defaults resource_class: Comment, collection_name: "comments", instance_name: "comment"
  before_action :verify_admin?

  protected

    def permitted_params
      params.fetch(:comment, {}).permit(:content, :user_id)
    end

    def collection
      @comments ||= end_of_association_chain.with_keywords(params[:name]).page(params[:page])
    end
end
