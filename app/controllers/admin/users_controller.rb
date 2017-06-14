class Admin::UsersController < AdminController
  defaults resource_class: User, collection_name: 'users', instance_name: 'user'

  protected
  def permitted_params
    params.fetch(:user, {}).permit(:email, :password, user_profile: [:name])
  end
end
