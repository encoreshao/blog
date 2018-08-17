# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/site_links/index", type: :view do
  before(:each) do
    assign(:site_links, [
      SiteLink.create!(
        name: "Name",
        url: "Url",
        site_group: ""
      ),
      SiteLink.create!(
        name: "Name",
        url: "Url",
        site_group: ""
      )
    ])
  end

  it "renders a list of admin/site_links" do
    render
    assert_select "tr>td", text: "Name".to_s, count: 2
    assert_select "tr>td", text: "Url".to_s, count: 2
    assert_select "tr>td", text: "".to_s, count: 2
  end
end
