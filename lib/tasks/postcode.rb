require 'rubygems'
require 'json'
require 'open-uri'

@lname = Array.new
@lpostcode = Array.new

print "Enter the postcode: "
postcode = gets.chomp

postcode = postcode.to_i

if postcode < 3000 || postcode > 3996
  puts "Post Code Does not exist"
elsif
  @postcode = postcode.to_s

  doc = open("http://v0.postcodeapi.com.au/suburbs/#{@postcode}.json").read
  data = JSON.parse(doc)
  if data.any? == false
    puts "Post code does not exist"
  elsif
    data.each do |d|
       @lname << d["name"]
       @lpostcode << d["postcode"]
    end
  end
end
