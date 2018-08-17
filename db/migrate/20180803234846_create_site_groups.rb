# frozen_string_literal: true

class CreateSiteGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :site_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
