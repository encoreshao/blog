RSpec.describe Article do
  let (:article) { Article.make! }

  it 'Should be include title when create article' do
    expect(article.title.present?).to be_truthy
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
