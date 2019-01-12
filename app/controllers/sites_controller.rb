# frozen_string_literal: true

class SitesController < ApplicationController
  layout "articles"

  caches_action :index, expires_in: 4.hours
  caches_action :author, expires_in: 2.days

  def index; end

  def author; end

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
