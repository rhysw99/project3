# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'rubygems'
require 'open-uri'
require 'csv'

# Put all postcodes and their associated lat/long into database.
csv_file = File.read("data/postcodes.csv")
CSV.foreach("data/postcodes.csv", converters: :numeric, :headers => true) do |row|
  Postcode.create!(row.to_hash)
end
