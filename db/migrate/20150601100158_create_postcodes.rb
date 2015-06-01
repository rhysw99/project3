class CreatePostcodes < ActiveRecord::Migration
  def change
    create_table :postcodes do |t|
      t.string :postcode
      t.string :name
      t.float :latitude
      t.float :longitude
      t.timestamps null: false
    end
  end
end
