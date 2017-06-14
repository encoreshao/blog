class CreateKindeditorAssets < ActiveRecord::Migration[5.1]
  def self.up
    create_table :kindeditor_assets do |t|
      t.string :asset
      t.integer :file_size
      t.string :file_type
      t.integer :owner_id
      t.string :owner_type
      t.string :asset_type # list by kindeditor: image, file, media, flash
      t.timestamps
    end
  end

  def self.down
    drop_table :kindeditor_assets
  end
end

