# frozen_string_literal: true

class Admin::TagsController < AdminController
  defaults resource_class: Tag, collection_name: "tags", instance_name: "tag"
  before_action :verify_admin?

  def update
    update! { admin_tags_path }
  end

  protected

    def tag_params
      params.fetch(:tag, {}).permit(:name, :permalink)
    end

    def collection
      @tags ||= end_of_association_chain.includes([:articles]).fuzzy_search(params[:name]).page(params[:page])
    end
end
