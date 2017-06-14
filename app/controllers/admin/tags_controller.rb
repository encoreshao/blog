class Admin::TagsController < AdminController
  defaults resource_class: Tag, collection_name: 'tags', instance_name: 'tag'

  def update
  	update! { admin_tags_path }
  end

  protected
  def tag_params
    params.fetch(:tag, {}).permit(:name)
  end
end
