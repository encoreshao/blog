class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories do |t|
      t.string :name_zh
      t.string :name_en
      t.string :permalink
      t.integer :articles_count, default: 0

      t.timestamps
    end
  end
end
