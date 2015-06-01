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

# Retrieve weather staions and associate with postcode.
@lines = Array.new
@fields = Array.new

postcodes = Postcode.all

doc = open("ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/lists_by_element/numeric/numVIC_139.txt"){|f| f.read }

text_file = File.new("data_text.txt","w+")
text_file.write(doc)
text_file.close

File.open("data_text.txt") do |in_file|
  File.open("test.csv", 'w') do |out_file| #the 'w' opens the file for writing
    in_file.each{|line| out_file << line.squeeze('/\n').gsub('/\n', ',') }
  end # closes test.csv
end # closes test.txt

CSV.foreach("test.csv") do |row|
  @lines << row[0]
end

@lines = @lines.slice(4..2296)

@lines.each do |line|
  @fields << line.split(' ')
end

@fields.each do |a|
  temp = a.to_a.reverse.drop(7)
  # Construct the name
  name = ""
  (temp.size - 2).downto(2) do |i|
    name = name + temp[i]
  end
  
  hash = Hash.new
  hash[:longitude] = temp[0].to_f
  hash[:latitude] = temp[1].to_f
  hash[:location_id] = name

  closest_dist = Float::MAX
  best_postcode = 0

   postcodes.each do |postcode|
     new_dist = Math.sqrt((hash[:longitude]-postcode.longitude)**2 + (hash[:latitude]-postcode.latitude)**2)
     if (new_dist < closest_dist)
       closest_dist = new_dist
       best_postcode = postcode.postcode
     end
   end

  hash[:postcode] = best_postcode
  
  Location.create(hash)
end

File.delete("data_text.txt")
File.delete("test.csv")
