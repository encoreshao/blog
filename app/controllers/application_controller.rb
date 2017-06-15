class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale

  def set_locale
  	I18n.locale = params[:locale] || I18n.default_locale
  end

   def after_sign_out_path_for(copasser)
    new_user_session_path
  end
end
