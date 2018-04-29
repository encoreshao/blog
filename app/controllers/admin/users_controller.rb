# frozen_string_literal: true

class Admin::UsersController < AdminController
  defaults resource_class: User, collection_name: "users", instance_name: "user"
  before_action :verify_admin?, except: %i[show edit update]
  before_action :verify_permit?, only: %i[show edit update]

  def update
    if resource.update_without_password(user_params)
      redirect_to admin_user_path(resource)
    else
      render :edit
    end
  end

  protected

    def user_params
      params.fetch(:user, {}).permit(:name, :email, :password, :title, :link, :introduction, :avatar)
    end

    def collection
      @users ||= end_of_association_chain.with_keywords(params[:name]).page(params[:page])
    end

    def verify_permit?
      redirect_to admin_root_path unless admin? || resource.id == current_user.id
    end
end
