class ArticleTag < ApplicationRecord
  belongs_to :article
  belongs_to :tag
end

# == Schema Information
#
# Table name: article_tags
#
#  id         :integer          not null, primary key
#  article_id :integer
#  tag_id     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
