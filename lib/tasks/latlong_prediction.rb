# Method used for prediction of rainfall, temperature, wind speed and direction.
# This should probably go into the controller and be called by a method that
# serves one of the http GET requests.
# Currently does not support inserting fetched data into a table, will maybe
# implement once data_controller has a create method.

require 'nokogiri'
require 'open-uri'
require 'json'
require 'openssl'
require 'date'

require_relative '661561-project-one'
	
BASE_URL = 'https://api.forecast.io/forecast'
API_KEY = '20b18266be21cbcbb6c389c460bd7137'
MTOS 	= 60 		# minute to second factor
ITOMM 	= 1000/2.54 	# inch to millimetre factor
MTOKM 	= 1.61 		# mile to kilometre factor
REFER 	= 60 		# minutes into the past to refer to
INTER 	= 30 		# minutes between each datapoint

def get_data(lat, long, time_current)
	
	time_earliest = time_current - REFER * MTOS
	
	data = Hash.new
	(time_earliest..time_current).step(INTER * MTOS) do |time|
		#puts Time.at(time)
		
		lat_long = lat.to_s + "," + long.to_s
		request_uri = URI.parse("#{BASE_URL}/#{API_KEY}/#{lat_long},#{time}")
		forecast = JSON.parse(open(request_uri, 
			{ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read)
		current = forecast['currently']
		
		# rainfall, temperature, wind_dir, wind_spd, updated, loc_id?
		# need controller methods for create if we want to insert
		# data retrieved for predictions into table
		data[time] = Hash.new
		data[time]['rainfall'] = current['precipIntensity'] * ITOMM * 
			current['precipProbability']
		data[time]['temperature'] = (current['temperature'] - 32) * 5/9
		data[time]['wind_speed'] = current['windSpeed'] * MTOKM
		data[time]['wind_dir'] = current['windBearing']
		data[time]['observed'] = current['time']
	end
	return data
end

# period in minutes
def get_predictions(lat, long, period)
	
	time_current = Time.now.to_i
	time_latest = time_current + period * MTOS
	interval = 10 * MTOS
	
	time = Array.new
	rain = Array.new
	temp = Array.new
	wind_spd = Array.new
	wind_dir = Array.new
	#data = get_data(-37.7993, 144.9615, time_current) # test values
	data = get_data(lat, long, time_current)
	data.keys.each do |i|
		# use these for regressions, with x array as time and y array as
		# the corresponding weather data array
		time << i - data.keys[0] + 1
		rain << data[i]['rainfall']
		temp << data[i]['temperature']
		wind_spd << data[i]['wind_speed']
		wind_dir << data[i]['wind_dir']
	end
	
	regressions = Hash.new
	regressions['rainfall'] = perform_regression(time, rain, 'polynomial')
	regressions['temperature'] = perform_regression(time, temp, 'polynomial')
	regressions['wind_speed'] = perform_regression(time, wind_spd, 'polynomial')
	regressions['wind_dir'] = perform_regression(time, wind_dir, 'polynomial')
	
	predictions = Hash.new
	(time_current..time_latest).step(interval) do |time|
		predictions[time] = Hash.new
		regressions.keys.each do |reg|
			sum = 0
			count = 0
			regressions[reg]['coefficients'].each do |i|
				sum += i * (time - time_current)**count
				count += 1
			end
			predictions[time][reg] = sum
		end
		predictions[time]['observed'] = time
	end
	return predictions
end

# tests

#preds = get_predictions(0, 0, 0)
#preds.keys.each do |time|
#	preds[time].keys.each do |params|
#		puts params.to_s + " : " + preds[time][params].to_s
#	end
#end


#data = get_data(-37.7993, 144.9615, Time.now.to_i)
#data.keys.each do |time|
#	data[time].keys.each do |param|
#		puts param + " : " + data[time][param].to_s
#	end
#end

#results = perform_regression([1, 2, 2], [2, 4, 6], 'polynomial')
#puts results['coefficients']
#puts results.values
#equation = generate_equation(results['coefficients'], results['constant'], 'polynomial')
#puts equation


