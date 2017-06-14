class CreateArticleTags < ActiveRecord::Migration[5.1]
  def change
    create_table :article_tags do |t|
      t.references :article, foreign_key: true
      t.references :tag, foreign_key: true

      t.timestamps
    end
  end
end
