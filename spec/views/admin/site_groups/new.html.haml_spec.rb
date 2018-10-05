# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/site_groups/new", type: :view do
  before(:each) do
    assign(:site_group, @site_group = SiteGroup.new(name: "Name"))
  end

  it "renders new site_group form" do
    render

    assert_select "form[action=?][method=?]", admin_site_groups_path, "post" do

      assert_select "input[name=?]", "site_group[name]"
    end
  end
end
