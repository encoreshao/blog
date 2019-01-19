# frozen_string_literal: true

class Pages::FullpanelsController < PagesController
  %i[index typed slides slack_logo].each do |method_name|
    caches_action method_name, expires_in: Rails.env.development? ? 1.seconds : 2.days

    def method_name
    end
  end
end
