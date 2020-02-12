# frozen_string_literal: true

class Admin::CategoriesController < AdminController
  defaults resource_class: Category, collection_name: "categories", instance_name: "category"
  before_action :verify_admin?

  def update
    update! { admin_categories_path }
  end

  protected

  def category_params
    params.fetch(:category, {}).permit(:name_zh, :name_en, :permalink)
  end

  def collection
    @categories ||= end_of_association_chain.fuzzy_search(params[:name]).page(params[:page])
  end
end
