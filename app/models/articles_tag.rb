# frozen_string_literal: true

class ArticlesTag < ApplicationRecord
  validates :article_id, :tag_id, presence: true
  validates_uniqueness_of :article_id, scope: [:tag_id]

  belongs_to :article
  belongs_to :tag
end

# == Schema Information
#
# Table name: articles_tags
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  article_id :bigint(8)
#  tag_id     :bigint(8)
#
# Indexes
#
#  index_articles_tags_on_article_id  (article_id)
#  index_articles_tags_on_tag_id      (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (tag_id => tags.id)
#
