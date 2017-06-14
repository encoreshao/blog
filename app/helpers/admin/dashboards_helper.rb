module Admin::DashboardsHelper
  def admin_sidebar(model, path)
    class_name = 'nav-link'
    class_name += (model.table_name == controller_name) ? ' active' : ''

    content_tag :li, class: 'nav-item' do
      content_tag :a, class: class_name, href: path do
        model.model_name.human
      end
    end
  end
end
