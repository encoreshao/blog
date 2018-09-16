# frozen_string_literal: true

module ApplicationHelper
  def site_title
    if article_pages?
      article_page_title
    elsif fullpanel_pages?
      "#{I18n.t("site_title")} - 单页应用"
    else
      I18n.t("site_title")
    end
  end

  def site_description
    if article_pages?
      "#{article_page_title} - #{I18n.t('author')}"
    else
      I18n.t("description")
    end
  end

  def article_page_title
    "#{@article.title} - #{I18n.t('site_title')}"
  end

  def article_pages?
    controller_name == 'articles' && action_name == 'show'
  end

  def fullpanel_pages?
    controller_name == 'fullpanels'
  end

  def random_banner_image
    image_tag("photos/banner-#{rand(1..15)}.jpg", class: "attachment-blog-image size-blog-image wp-post-image")
  end

  def author_thumb_image
    image_tag("photos/encore.jpg", class: "attachment-small-thumb size-small-thumb wp-post-image")
  end

  def author_avatar
    image_tag("photos/encore.jpg", class: "avatar avatar-80 photo")
  end

  def wechat_image
    image_tag("photos/wechat200x200.png", class: "wechat")
  end

  def widget_categories
    Rails.cache.fetch("icmoc_widget_categories_with_#{params[:locale]}", expires_in: 1.hours) do
      attr_name = "name_#{params[:locale] || I18n.default_locale}"

      Category.where("articles_count > 0").select("permalink, #{attr_name}").map do |e|
        [e.send(attr_name.to_sym), e.permalink]
      end
    end
  end

  def audio_or_video_of_article(article)
    return video_of_article(article) if article.video?
    return audio_of_article(article) if article.audio?
  end

  def video_of_article(article)
    content_tag(:iframe, "", src: article.embed_link, frameborder: 0)
  end

  def audio_of_article(article)
    content_tag(:audio, "", controls: true, autoplay: false, loop: true, src: article.embed_link)
  end
end
