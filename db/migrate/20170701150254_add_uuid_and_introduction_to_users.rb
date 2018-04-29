# frozen_string_literal: true

class AddUuidAndIntroductionToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :uuid, :string
    add_column :users, :introduction, :text
  end
end
