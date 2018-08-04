class Admin::SiteGroupsController < AdminController
  defaults resource_class: SiteGroup, collection_name: "site_groups", instance_name: "site_group"

  private

    def site_group_params
      params.require(:site_group).permit(:name)
    end

    def collection
      @site_groups ||= end_of_association_chain.with_keywords(params[:name]).page(params[:page])
    end
end

