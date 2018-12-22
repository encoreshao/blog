# frozen_string_literal: true

class Pages::FullpanelsController < PagesController
  caches_action :index, expires_in: 2.days
  caches_action :typed, expires_in: 2.days
  caches_action :slides, expires_in: 2.days

  def index; end

  def typed; end

  def slides; end
end
