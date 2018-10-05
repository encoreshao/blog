# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/site_groups/index", type: :view do
  before(:each) do
    @site_groups = [
      SiteGroup.create!(
        name: "Name1"
      ),
      SiteGroup.create!(
        name: "Name2"
      )]
  end
end
