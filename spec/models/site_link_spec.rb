# frozen_string_literal: true

RSpec.describe SiteLink do

  it "should be able to create from the factory" do
    SiteLink.make!

    expect(SiteLink.count).to eq(1)
  end

end
