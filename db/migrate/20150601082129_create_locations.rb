class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
	    t.string :location_id
      t.float :latitude
      t.float :longitude
      t.string :postcode
      t.datetime :last_update
      t.timestamps null: false
    end
  end
end
