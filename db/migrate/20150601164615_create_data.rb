class CreateData < ActiveRecord::Migration
  def change
    create_table :data do |t|
      t.integer :location_id
      t.float :rainfall
      t.float :temperature
      t.string :wind_dir
      t.float :wind_speed
      t.integer :observed

      t.timestamps null: false
    end
  end
end
