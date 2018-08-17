# frozen_string_literal: true

module SitesHelper
  def site_groups
    SiteGroup.all.map { |e| [e.name, e.id] }
  end
end
