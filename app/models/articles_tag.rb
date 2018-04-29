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
#  id         :integer          not null, primary key
#  article_id :integer
#  tag_id     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
