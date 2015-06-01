class CreateData < ActiveRecord::Migration
  def change
    create_table :data do |t|
      t.integer :location_id
      t.float :rainfall
      t.float :temperature
      t.float :wind_dir
      t.float :wind_speed
      t.datetime :observed

      t.timestamps null: false
    end
  end
end
