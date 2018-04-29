# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.text :content
      t.integer :comment_id
      t.integer :comment_parent, default: 0
      t.string :name
      t.string :email
      t.string :link
      t.inet   :remote_ip
      t.references :user, foreign_key: true
      t.references :commentable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
