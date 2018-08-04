require 'rails_helper'

RSpec.describe "admin/site_groups/show", type: :view do
  before(:each) do
    @site_group = assign(:site_group, Admin::SiteGroup.create!(
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
