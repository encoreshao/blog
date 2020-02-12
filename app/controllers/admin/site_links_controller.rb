# frozen_string_literal: true

class Admin::SiteLinksController < AdminController
  defaults resource_class: SiteLink, collection_name: "site_links", instance_name: "site_link"
  before_action :verify_admin?

  private

  def site_link_params
    params.require(:site_link).permit(:name, :url, :site_group_id, :email, :enabled)
  end

  def collection
    @site_links ||= end_of_association_chain.fuzzy_search(params[:name]).page(params[:page]).order("created_at ASC")
  end
end
