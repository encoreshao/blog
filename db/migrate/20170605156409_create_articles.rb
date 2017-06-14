class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :permalink
      t.text :content
      t.boolean :is_published, default: false
      t.date :published_at
      t.datetime :last_reviewed_at
      t.string :reprinted_source
      t.string :reprinted_link
      t.references :category, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
