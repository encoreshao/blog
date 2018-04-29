# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale

  helper_method :mobile_device?

  def mobile_device?
    mobile? || ipad?
  end

  def mobile?
    (request.user_agent =~ /iPhone|Android|Nexus|Samsung|HTC/)
  end

  def ipad?
    request.user_agent =~ /iPad/
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def after_sign_in_path_for(_resource)
    admin_root_path
  end

  def after_sign_out_path_for(_resource)
    new_user_session_path
  end
end
