class AdminController < InheritedResources::Base
  before_action :authenticate_user!

  protect_from_forgery with: :exception
  layout 'admin'
end
