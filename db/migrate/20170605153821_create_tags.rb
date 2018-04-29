# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.string :name
      t.string :permalink

      t.timestamps
    end
  end
end
