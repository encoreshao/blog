require 'rails_helper'

RSpec.describe "admin/site_links/new", type: :view do
  before(:each) do
    assign(:site_link, Admin::SiteLink.new(
      :name => "MyString",
      :url => "MyString",
      :site_group => ""
    ))
  end

  it "renders new site_link form" do
    render

    assert_select "form[action=?][method=?]", site_links_path, "post" do

      assert_select "input[name=?]", "site_link[name]"

      assert_select "input[name=?]", "site_link[url]"

      assert_select "input[name=?]", "site_link[site_group]"
    end
  end
end
