RSpec.describe ArticlesTag do
  let (:articles_tag) { ArticlesTag.make! }

  it 'Should be present when create ArticlesTag' do
    expect(articles_tag.present?).to be_truthy
  end
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
