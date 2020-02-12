# frozen_string_literal: true

class SitesController < ApplicationController
  layout "articles"

  %i[index author].each do |method_name|
    caches_action method_name, expires_in: Rails.env.development? ? 1.seconds : 2.days

    def method_name
    end
  end

  def feedback
    if request.post?
      @site = SiteLink.new(site_link_params)
      if @site.save
        flash[:notice] = "提交成功！"

        redirect_to feedback_sites_path
      else
        render "feedback"
      end
    else
      @site = SiteLink.new
    end
  end

  private
  def site_link_params
    params.fetch(:site_link, {}).permit(:name, :email, :url)
  end
end
