class Admin::UsersController < AdminController
  defaults resource_class: User, collection_name: 'users', instance_name: 'user'
  before_action :verify_admin?

  protected
  def permitted_params
    params.fetch(:user, {}).permit(:email, :password, user_profile: [:name])
  end

  def collection
  	@users ||= end_of_association_chain.with_keywords(params[:name]).page(params[:page])
  end
end
