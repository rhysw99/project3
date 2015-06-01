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
CSV.foreach("data/postcodes.csv") do |row|
	hash = Hash.new
	hash[:postcode] = row[0]
	hash[:name] = row[1]
	hash[:latitude] = row[3]
	hash[:longitude] = row[4]
	new = Postcode.create(hash)
  new.save
end

# Retrieve weather staions and associate with postcode.
@line = Array.new
@fields = Array.new

postcodes = Postcode.all

doc = open('ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/lists_by_element/numeric/numVIC_139.txt'){|f| f.read }

text_file = File.new("data_text.txt","w+")
text_file.write(doc)
text_file.close

File.open("data_text.txt") do |in_file|
  File.open("test.csv", 'w') do |out_file| #the 'w' opens the file for writing
    in_file.each{|line| out_file << line.squeeze('/\n').gsub('/\n', ',') }
  end # closes test.csv
end # closes test.txt

CSV.foreach("test.csv") do |row|
  @line << row[0]
end

@line = @line.slice(4..2296)

@fields.each do |line|
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
  hash[:location_id] = temp[temp.size - 1].to_i
  hash[:longitude] = temp[0].to_f
  hash[:latitude] = temp[1].to_f
  hash[:name] = name

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
  
  l = Location.create(hash)
  l.save
end

File.delete("data_text.txt")
File.delete("test.csv")
