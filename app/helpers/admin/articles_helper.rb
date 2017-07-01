module Admin::ArticlesHelper
  def full_atricle_tags
    Tag.all.select("permalink, name").map do |e|
      [e.name, e.permalink]
    end
  end

  def atricle_categories
  	attr_name = "name_#{params[:locale] || I18n.default_locale}"

    Category.all.select("id, #{attr_name}, permalink").map do |e|
      [e.send(attr_name.to_sym), e.id, {'data-type' => e.permalink}]
     end
  end
end
