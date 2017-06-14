class Article < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :category, optional: true, counter_cache: true

  scope :published, -> { where(is_published: true) }

  validates :title, :permalink, :user_id, :category_id, :content, presence: true

  def author_name
    user.try(:name)
  end

  def category_name(locale)
    category.send("name_#{locale || 'en'}".to_sym)
  end

  def last_reviewed_date
    last_reviewed_at && last_reviewed_at.strftime('%b %d, %Y')
  end

  def published_date
    published_at && published_at.strftime('%b %d, %Y')
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
#  last_reviewed_at :datetime
#  reprinted_source :string
#  reprinted_link   :string
#  category_id      :integer
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
