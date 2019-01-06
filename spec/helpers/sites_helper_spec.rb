# frozen_string_literal: true

require "rails_helper"

RSpec.describe SitesHelper, type: :helper do
  it 'should contains custom class nav-link' do
    expect(helper.custom_menu_item('link1', 'text')).to match(/nav-link/)
  end

  it 'returns yes or no options' do
    expect(helper.switch_options).to eq([['否', '0'], ['是', '1']])
  end
end
