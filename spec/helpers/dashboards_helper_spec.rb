# frozen_string_literal: true

RSpec.describe DashboardsHelper do
  describe "Recently replied to the articles" do
    it "should return empty when without articles" do
      expect(helper.recently_replied_to_the_articles).to eq([])
    end
  end

  describe "Display animation" do
    it "should be return false when the controller is articles" do
      allow(helper).to receive(:controller_name).and_return("articles")

      expect(helper.animation?).to eq(false)
    end

    it "should be return true when the controller is dashboards and without other params" do
      allow(helper).to receive(:controller_name).and_return("dashboards")

      expect(helper.animation?).to eq(true)
    end
  end
end
