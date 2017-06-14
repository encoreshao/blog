class Admin::CategoriesController < AdminController
  defaults resource_class: Category, collection_name: 'categories', instance_name: 'category'

  def update
  	update! { admin_categories_path }
  end

  protected
  def permitted_params
    params.fetch(:category, {}).permit(:name_zh, :name_en)
  end
end
