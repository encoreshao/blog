# frozen_string_literal: true

module SitesHelper
  def site_groups
    SiteGroup.all.map { |e| [e.name, e.id] }
  end

  def navbar_menu_item(link, controller_and_action, nav_name)
    active = "active" if controller_and_action == "#{controller_name}_#{action_name}"

    content_tag(:li, class: "nav-item #{active}") do
      content_tag(:a, I18n.t("navigation.#{nav_name}"), href: link, class: "nav-link")
    end
  end

  def switch_options
    [[I18n.t("action.switch_no"), "0"], [I18n.t("action.switch_yes"), "1"]]
  end
end
