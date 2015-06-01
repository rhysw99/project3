#################################
# Rhys Williams
# 661561
# rhysw@student.unimelb.edu.au
#################################

# This script uses lambdas that are stored in the database.
# The code fragments can be found in the file
# weather_data_retriever_lambdas.rb for marking purposes

require 'nokogiri'
require 'open-uri'
require 'json'
require 'yaml'

# Takes a Source object which contains the attributes URL, hashmap of keys and a hashmap
# of data transformations.
# Takes the URL of a webpage and a hashmap of keys and the corresponding css to match
# Parses the HTML page and returns an array of hashes which have the same structure as
# a WeatherDatum object.
# We can reuse this function for any webpage by providing a different hashmap containing the css
# to parse.
def parse_HTML_source source
  doc = Nokogiri::HTML(open(source.url))

  # A hashmap of keys and the associated HTML code to match to obtain the desired value
  elements = source.tags
  # A hashmap of transformations that may be required to transform the data from each
  # data source to the same format.
  transforms = source.transforms

  data = Array.new
  # Loop through each attribute that we are parsing
  elements.each do |key, value|
    set = doc.xpath(value)
    count = 0
    # For each weather station
    set.each do |element|
      data[count] ||= Hash.new
      dataPoint = element.text
      if (transforms[key])
        trans_code = eval(transforms[key])
        dataPoint = trans_code.call(dataPoint)
      end
      # Need to add more general error checking if more sources are added
      # If adding another data source this needs to be modified to account for cases
      # where no value is specified as they may have a different representation
      data[count][key] = (dataPoint != "-" ? dataPoint : nil)
      count += 1
    end
    # Add source id to each entry
    data.each do |element|
      element[:source_id] = source.id
    end
  end
  
  return data
end


# Takes a source object which contains a url in which to retrieve data from
# The data can be transformed using the hash transforms stored inside the source object
# constructs a hash map of the same structure as a WeatherDatum object and returns the hash.
def parse_JSON_API source
  data = Array.new
  Station.all.each_with_index do |station, i|
    location = station["coordinates"]
    request_url = source.url % {location: "#{location}"}
    forecast = JSON.parse(open(request_url).read)
    data[i] = Hash.new

    # Source.transforms is a lambda which is stored in the database for each source
    # It is used to assign the correct tags to each key of the data[i] array and transform
    # the data into the correct forms
    eval(source.transforms).call
  end
  return data
end

# Loop through all HTML sources
Source.where(:source_type => "HTML").each do |source|
  data = parse_HTML_source(source)
  data.each do |hash|
    entry = WeatherDatum.create(hash)
  end
end

# Loop through all API sources
Source.where(:source_type => "API").each do |source|
  data = parse_JSON_API(source)
  data.each do |hash|
    entry = WeatherDatum.create(hash)
  end
end
