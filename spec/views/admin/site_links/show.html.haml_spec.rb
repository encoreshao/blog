require 'rails_helper'

RSpec.describe "admin/site_links/show", type: :view do
  before(:each) do
    @site_link = assign(:site_link, Admin::SiteLink.create!(
      :name => "Name",
      :url => "Url",
      :site_group => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Url/)
    expect(rendered).to match(//)
  end
end
