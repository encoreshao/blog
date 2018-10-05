# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/site_groups/show", type: :view do
  before do
    assign(:site_group, @site_group = SiteGroup.create!(name: "Name"))
  end

  it "renders Name in view" do
    render

    expect(rendered).to match(/Name/)
  end
end
