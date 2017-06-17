module ApplicationHelper
	def banner_iamge_url
		"/assets/photos/banner-00#{1+rand(6)}.jpg"
	end

  def widget_categories
    attr_name = "name_#{params[:locale] || I18n.default_locale}"

    Category.all.select("permalink, #{attr_name}").map do |e|
      [e.send(attr_name.to_sym), e.permalink]
    end
  end

	def friendly_links
		{
			'Ekohe' => 'https://ekohe.com'
		}
	end
end
