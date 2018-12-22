# frozen_string_literal: true

class Pages::HomepagesController < PagesController
  caches_action :index, expires_in: 2.days

  def index; end
end
