# frozen_string_literal: true

class AdminController < InheritedResources::Base
  protect_from_forgery with: :exception
  layout "admin"

  before_action :authenticate_user!
  helper_method :admin?

  private

    def admin?
      current_user.admin?
    end

    def verify_admin?
      redirect_to admin_root_path unless admin?
    end
end
