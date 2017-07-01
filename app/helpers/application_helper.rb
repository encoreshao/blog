module ApplicationHelper
  def site_title
    return I18n.t('site_title') if controller_name == 'dashboards'

    "#{@article.title} - #{I18n.t('site_title')}"
  end

  def site_description
    return I18n.t('description') if controller_name == 'dashboards'

    "#{@article.title} - #{I18n.t('site_title')} - #{I18n.t('author')}"
  end

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
    image_tag("photos/wechat200x200.png", class: 'wechat')
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

  def audio_or_video_of_article(article)
    return video_of_article(article) if article.video?
    return audio_of_article(article) if article.audio?
  end

  def video_of_article(article)
    content_tag(:iframe, '', src: article.embed_link, frameborder: 0)
  end

  def audio_of_article(article)
    content_tag(:audio, '', controls: true, autoplay: false, loop: true, src: article.embed_link)
  end
end
