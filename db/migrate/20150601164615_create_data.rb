class CreateData < ActiveRecord::Migration
  def change
    create_table :data do |t|
      t.integer :location_id
      t.float :rainfall
      t.float :temperature
      t.string :wind_dir
      t.float :wind_speed
      t.datetime :observed
      t.float :temperature_predicitons
      t.float :temp_prob
      t.float :rainfall_predictions
      t.float :rain_prob
      t.float :wind_speed_predicitons
      t.float :winds_prob
      t.string :wind_dir_predictions
      t.float :windd_prob

      t.timestamps null: false
    end
  end
end
