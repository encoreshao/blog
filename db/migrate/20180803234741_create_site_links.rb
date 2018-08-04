class CreateSiteLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :site_links do |t|
      t.string :name
      t.string :url
      t.references :site_group

      t.timestamps
    end
  end
end
