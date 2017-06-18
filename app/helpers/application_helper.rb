module ApplicationHelper
	def banner_iamge_url
		"/assets/photos/banner-00#{1+rand(6)}.jpg"
	end

  def widget_categories
    Rails.cache.fetch("icmoc_widget_categories_with_#{params[:locale]}", expires_in: 1.hours) do
      attr_name = "name_#{params[:locale] || I18n.default_locale}"

      Category.where("articles_count > 0").select("permalink, #{attr_name}").map do |e|
        [e.send(attr_name.to_sym), e.permalink]
      end
    end
  end

	def friendly_links
		{
			'Ekohe' => 'https://ekohe.com'
		}
	end
end
