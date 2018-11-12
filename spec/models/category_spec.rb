# frozen_string_literal: true

RSpec.describe Category do
  let (:category) { Category.make! }

  it "Should be with all attributes when create Category" do
    expect(category.name_zh.present?).to be_truthy
    expect(category.name_en.present?).to be_truthy
    expect(category.permalink.present?).to be_truthy
  end
end

# == Schema Information
#
# Table name: categories
#
#  id             :bigint(8)        not null, primary key
#  articles_count :integer          default(0)
#  name_en        :string
#  name_zh        :string
#  permalink      :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
