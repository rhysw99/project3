class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :location_id
      t.float :latitude
      t.float :longitude
      t.float :last_update
      t.string :postcode

      t.timestamps null: false
    end
  end
end
