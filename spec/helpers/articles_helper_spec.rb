# frozen_string_literal: true

RSpec.describe ArticlesHelper do
  let(:email) { "test@email.com" }
  let(:avatar_url) { "https://www.gravatar.com/avatar/93942e96f5acd83e2e047ad8fe03114d" }

  it "should return avatar URL" do
    expect(helper.gravatar_url(email)).to eq(avatar_url)
  end
end
