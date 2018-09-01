# frozen_string_literal: true

module SitesHelper
  def site_groups
    SiteGroup.all.map { |e| [e.name, e.id] }
  end

  def navbar_menu_item(link, controller_and_action, text)
    active = "active" if controller_and_action == "#{controller_name}_#{action_name}"

    content_tag(:li, class: "nav-item #{active}") do
      content_tag(:a, text, href: link, class: "nav-link")
    end
  end
end
