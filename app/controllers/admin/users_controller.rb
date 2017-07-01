class Admin::UsersController < AdminController
  defaults resource_class: User, collection_name: 'users', instance_name: 'user'
  before_action :verify_admin?

  def update
    if resource.update_without_password(permitted_params)
      redirect_to admin_user_path(resource)
    else
      render :new
    end
  end

  protected
  def permitted_params
    params.fetch(:user, {}).permit(:email, :password, :name, :link, :avatar)
  end

  def collection
  	@users ||= end_of_association_chain.with_keywords(params[:name]).page(params[:page])
  end
end
