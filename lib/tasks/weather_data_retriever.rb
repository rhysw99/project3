#################################
# Rhys Williams
# 661561
# rhysw@student.unimelb.edu.au
#################################

require 'nokogiri'
require 'open-uri'
require 'yaml'

# Takes a Source object which contains the attributes URL, hashmap of keys and a hashmap
# of data transformations.
# Takes the URL of a webpage and a hashmap of keys and the corresponding css to match
# Parses the HTML page and returns an array of hashes which have the same structure as
# a WeatherDatum object.
# We can reuse this function for any webpage by providing a different hashmap containing the css
# to parse.
def parse_HTML_source url
  doc = Nokogiri::HTML(open(url))

  # A hashmap of keys and the associated HTML code to match to obtain the desired value
  elements = {:location_url=> "//tr//th/a/@href", :location_id=>"//tr//th//a", :rainfall=>"//td[contains(@headers, '-rainsince9am')]", :temperature=>"//td[contains(@headers, '-tmp')]", :wind_dir=>"//td[contains(@headers, '-wind-dir')]", :wind_speed=>"//td[contains(@headers, '-wind-spd-kmh')]", :observed=>"//td[contains(@headers, '-datetime')]"}
  # A hashmap of transformations that may be required to transform the data from each
  # data source to the same format.
  transforms = {:observed =>"lambda {|value| Time.parse(value).to_i}", :location_id=>"lambda {|value| Location.find_by(location_id: \"\#{value}\")}"}

  data = Array.new
  # Loop through each attribute that we are parsing
  elements.each do |key, value|
    set = doc.xpath(value)
    count = 0
    simple_name = ""
    # For each weather station
    set.each do |element|
      data[count] ||= Hash.new
      dataPoint = element.text
      if (transforms[key])
        if (key == :location_id)
          simple_name = dataPoint
        end
        trans_code = eval(transforms[key])
        dataPoint = trans_code.call(dataPoint)
      end

      if (key == :location_id)
        if (dataPoint.nil?)
          # Need to create a new location
          location_doc = Nokogiri::HTML(open("http://www.bom.gov.au"+data[count][:location_url]))
          location_name = simple_name
          location_lat = location_doc.xpath("//*[@id='content']/div[2]/table/tr/td[4]/text()").text.strip.to_f
          location_long = location_doc.xpath("//*[@id='content']/div[2]/table/tr/td[5]/text()").text.strip.to_f
          location_postcode = LocationsHelper.getPostcodeFromLatLong(location_lat, location_long)
          l = Location.create!({:location_id => location_name, :latitude=>location_lat, :longitude=>location_long, :postcode_id=>location_postcode})
          dataPoint = l
        end
        dataPoint = dataPoint.id
      end

      # Need to add more general error checking if more sources are added
      # If adding another data source this needs to be modified to account for cases
      # where no value is specified as they may have a different representation
      data[count][key] = (dataPoint != "-" ? dataPoint : nil)
      count += 1
    end    
  end
  
  return data
end

data = parse_HTML_source("http://www.bom.gov.au/vic/observations/vicall.shtml")
data.each do |hash|
  puts hash
  hash.delete(:location_url)
  entry = Datum.create!(hash)
  location = Location.find(hash[:location_id])
  location.last_update = hash[:observed]
  location.save
end