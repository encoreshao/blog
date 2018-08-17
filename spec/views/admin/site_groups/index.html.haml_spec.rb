# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/site_groups/index", type: :view do
  before(:each) do
    assign(:site_groups, [
      Admin::SiteGroup.create!(
        name: "Name"
      ),
      Admin::SiteGroup.create!(
        name: "Name"
      )
    ])
  end

  it "renders a list of admin/site_groups" do
    render
    assert_select "tr>td", text: "Name".to_s, count: 2
  end
end
