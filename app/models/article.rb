# frozen_string_literal: true

class Article < ApplicationRecord
  validates :title, :permalink, :user_id, :category_id, :content, presence: true

  belongs_to :user, optional: true
  delegate :name, to: :user, prefix: "author", allow_nil: true
  belongs_to :category, optional: true, counter_cache: true

  has_and_belongs_to_many :tags
  has_many :comments, as: :commentable

  scope :published, -> { where(is_published: true) }
  scope :sorting, -> { order("published_at DESC NULLS LAST") }
  scope :with_categories, ->(category_id) {
    return nil if category_id.nil?

    where(category_id: category_id)
  }
  scope :with_tags, ->(tag_id) {
    return nil if tag_id.nil?

    joins(:tags).where("articles_tags.tag_id = ?", tag_id)
  }
  scope :with_keywords, ->(keyword) {
    return nil if keyword.blank?

    criteria = ActiveRecord::Base.send(:sanitize_sql, keyword)
    where("LOWER(title) ILIKE LOWER(?)", "%#{criteria}%")
  }
  scope :with_owner, ->(current_user) {
    user_id = (current_user.admin? ? nil : current_user.id)
    return nil if user_id.nil?

    where(user_id: user_id)
  }

  after_update :cleaning_cache!

  def category_name(locale)
    category.send("name_#{locale || 'en'}".to_sym)
  end

  def embed?
    category&.embed?
  end

  def audio?
    category.audio?
  end

  def video?
    category.video?
  end

  def published_date
    published_at&.strftime("%Y-%m-%d")
  end

  def tag_names
    tags.select("name").map(&:name).join(", ")
  end

  def params
    return {} if published_at.blank?

    {
      year: published_at.year,
      month: published_at.month,
      day: published_at.day,
      permalink: permalink
    }
  end

  def cleaning_cache!
    WarmCaches::ActionCachingHelper.clean_article!(id)
  end
end

# == Schema Information
#
# Table name: articles
#
#  id               :integer          not null, primary key
#  title            :string
#  permalink        :string
#  content          :text
#  is_published     :boolean          default(FALSE)
#  published_at     :date
#  view_count       :integer          default(0)
#  likes_count      :integer          default(0)
#  dislike_count    :integer          default(0)
#  reprinted_source :string
#  reprinted_link   :string
#  category_id      :integer
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  embed_link       :string
#
