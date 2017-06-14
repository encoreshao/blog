module Admin::ArticlesHelper
  def full_atricle_tags
    attr_name = "name_#{params[:locale] || I18n.default_locale}"

    Category.all.select("id, #{attr_name}").map do |e|
      [e.send(attr_name.to_sym), e.id]
    end
  end
end
