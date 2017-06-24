RSpec.describe Tag do
  let (:tag) { Tag.make! }

  it 'Should be include name when create tag' do
    expect(tag.name.present?).to be_truthy
  end
end

# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string
#  permalink  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
