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
#  id             :integer          not null, primary key
#  name_zh        :string
#  name_en        :string
#  permalink      :string
#  articles_count :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
