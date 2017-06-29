module ApplicationHelper
  def random_banner_image
    image_tag("photos/banner-00#{1+rand(6)}.jpg", class: 'attachment-blog-image size-blog-image wp-post-image')
  end

  def author_thumb_image
    image_tag("photos/encore.jpg", class: 'attachment-small-thumb size-small-thumb wp-post-image')
  end

  def author_avatar
    image_tag("photos/encore.jpg", class: 'avatar avatar-80 photo')
  end

  def wechat_image
    image_tag("photos/wechat200x200.png", class: 'avatar avatar-80 photo')
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
