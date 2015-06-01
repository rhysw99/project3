require 'rubygems'
require 'open-uri'
require 'csv'

@station_id                   = Array.new
@station_name                 = Array.new
@location_latitude            = Array.new
@location_longitude           = Array.new
@first_name                   = Array.new

@a1 = Array.new
@a2 = Array.new

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
  @a1 << row[0]
end

@a1 = @a1.slice(4..2296)

@a1.each do |a1|
  @a2 << a1.split(' ')
end

@a2.each do |a|
  temp = a.to_a.reverse.drop(7)
  # Construct the name
  name = ""
  (temp.size - 2).downto(2) do |i|
    name = name + " " + temp[i]
  end

  hash = Hash.new
  hash[:location_id] = temp[temp.size - 1].to_i
  hash[:longitude] = temp[0].to_f
  hash[:latitude] = temp[1].to_f
  hash[:name] = name

  Location.create(hash)
end
