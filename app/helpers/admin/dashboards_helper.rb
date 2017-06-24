module Admin::DashboardsHelper
  def admin_sidebar(nav_class, path)
    return unless admin? || ['dashboards', 'articles'].include?(nav_class)

    class_name = 'nav-link'
    class_name += (nav_class == controller_name) ? ' active' : ''

    content_tag :li, class: 'nav-item' do
      content_tag :a, class: class_name, href: path do
        content_tag :i, class: icon_name(nav_class) do
          " " + table_human_name(nav_class)
        end
      end
    end
  end

  def table_human_name(nav_class)
    return I18n.t('navigation.dashboards') if nav_class == 'dashboards'

    nav_class.singularize.titleize.constantize.model_name.human
  end

  def icon_name(nav_class)
    class_name = case nav_class
    when 'articles'
      'book'
    when 'categories'
      'building'
    when 'dashboards'
      'dashboard'
    else
      nav_class
    end

    "fa fa-#{class_name}"
  end
end
