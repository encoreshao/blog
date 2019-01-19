# frozen_string_literal: true

class Pages::HomepagesController < PagesController
  caches_action :index, expires_in: Rails.env.development? ? 1.seconds : 2.days

  def index; end
end
