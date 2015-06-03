class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :location_id
      t.float :latitude
      t.float :longitude
      t.integer :last_update
      t.string :postcode_id

      t.timestamps null: false
    end
    add_index :locations, :id
  end
end
