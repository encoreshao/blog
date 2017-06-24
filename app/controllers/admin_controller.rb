class AdminController < InheritedResources::Base
  protect_from_forgery with: :exception
  layout 'admin'

  before_action :authenticate_user!
  helper_method :admin?

  private 
  def admin?
  	current_user.admin?
  end
end
