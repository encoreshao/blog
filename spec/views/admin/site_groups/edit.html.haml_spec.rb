# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/site_groups/edit", type: :view do
  before(:each) do
    @site_group = assign(:site_group, SiteGroup.create!(
                                        name: "MyString"
    ))
  end

  it "renders the edit site_group form" do
    render

    assert_select "form[action=?][method=?]", admin_site_group_path(@site_group), "post" do

      assert_select "input[name=?]", "site_group[name]"
    end
  end
end
