class AddFieldsToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :last_updated, :datetime
    add_column :locations, :postcode, :string
	remove_column :locations, :location_id
	rename_column :locations, :name, :location_id
  end
end
