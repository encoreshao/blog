# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/site_links/edit", type: :view do
  before(:each) do
    @site_link = assign(:site_link, SiteLink.create!(
                                      name: "MyString",
                                      url: "MyString",
                                      site_group: ""
    ))
  end

  it "renders the edit site_link form" do
    render

    assert_select "form[action=?][method=?]", site_link_path(@site_link), "post" do

      assert_select "input[name=?]", "site_link[name]"

      assert_select "input[name=?]", "site_link[url]"

      assert_select "input[name=?]", "site_link[site_group]"
    end
  end
end
