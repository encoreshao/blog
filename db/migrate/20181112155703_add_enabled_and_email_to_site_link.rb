# frozen_string_literal: true

class AddEnabledAndEmailToSiteLink < ActiveRecord::Migration[5.2]
  def change
    add_column :site_links, :enabled, :boolean, default: false
    add_column :site_links, :email, :string
  end
end
