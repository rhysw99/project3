class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.integer :location_id
	    t.string :name
      t.float :latitude
      t.float :longitude
      t.timestamps null: false
    end
  end
end
