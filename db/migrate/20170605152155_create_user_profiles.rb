class CreateUserProfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :user_profiles do |t|
    	t.references :user, foreign_key: true
      t.string :name
      t.string :avatar
      t.string :link

      t.timestamps
    end
  end
end
