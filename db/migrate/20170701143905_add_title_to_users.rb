# frozen_string_literal: true

class AddTitleToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :title, :string
  end
end
