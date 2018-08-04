# frozen_string_literal: true

module Admin::DashboardsHelper
  def admin_sidebar(nav_class, path)
    return unless admin? || %w[dashboards articles].include?(nav_class)

    class_name = "nav-link"
    class_name += (nav_class == controller_name) ? " active" : ""

    content_tag :li, class: "nav-item" do
      content_tag :a, class: class_name, title: table_human_name(nav_class), href: path do
        content_tag :i, class: icon_name(nav_class) do
          " " + table_human_name(nav_class) if class_name.match(/active/) || mobile_device?
        end
      end
    end
  end

  def table_human_name(nav_class)
    return I18n.t("navigation.dashboards") if nav_class == "dashboards"

    nav_class.singularize.titleize.gsub(/\ /, '').constantize.model_name.human
  end

  def icon_name(nav_class)
    class_name = case nav_class
                 when "articles"
                   "book"
                 when "categories"
                   "building"
                 when "dashboards"
                   "dashboard"
                 when 'site_groups'
                  'object-group'
                when 'site_links'
                  'link'
                 else
                   nav_class
                 end

    "fa fa-#{class_name}"
  end
end
