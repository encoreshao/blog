# frozen_string_literal: true

class AddEmbedLinkToArticles < ActiveRecord::Migration[5.1]
  def change
    add_column :articles, :embed_link, :string
  end
end
