class Admin::TagsController < AdminController
  defaults resource_class: Tag, collection_name: 'tags', instance_name: 'tag'
  before_action :admin?

  def update
  	update! { admin_tags_path }
  end

  protected
  def tag_params
    params.fetch(:tag, {}).permit(:name, :permalink)
  end

  def collection
  	@tags ||= end_of_association_chain.with_keywords(params[:name]).page(params[:page])
  end
end
