# frozen_string_literal: true

RSpec.describe Article do
  let (:article) { Article.make! }

  it "Should be include title when create article" do
    expect(article.title.present?).to be_truthy
  end

  it "Should be contains method `is_published_text`" do
    expect(article.is_published_text).to eq("否")
  end
end

# == Schema Information
#
# Table name: articles
#
#  id               :bigint(8)        not null, primary key
#  content          :text
#  dislike_count    :integer          default(0)
#  embed_link       :string
#  is_published     :boolean          default(FALSE)
#  likes_count      :integer          default(0)
#  permalink        :string
#  published_at     :date
#  reprinted_link   :string
#  reprinted_source :string
#  title            :string
#  view_count       :integer          default(0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  category_id      :bigint(8)
#  user_id          :bigint(8)
#
# Indexes
#
#  index_articles_on_category_id  (category_id)
#  index_articles_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (user_id => users.id)
#
