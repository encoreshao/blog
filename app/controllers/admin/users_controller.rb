class Admin::UsersController < AdminController
  defaults resource_class: User, collection_name: 'users', instance_name: 'user'
  before_action :verify_admin?

  def update
    if resource.update_without_password(user_params)
      redirect_to admin_user_path(resource)
    else
      render :edit
    end
  end

  protected
  def user_params
    params.fetch(:user, {}).permit(:name, :email, :password, :title, :link, :avatar)
  end

  def collection
  	@users ||= end_of_association_chain.with_keywords(params[:name]).page(params[:page])
  end
end
