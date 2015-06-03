json.extract! @cur_date, :date
json.locations do
	json.array!(@locations) do |location|
		json.id location.location_id
		json.lat location.latitude
		json.lon location.longitude
		json.last_update Time.at(location.last_update).strftime("%H:%M%P %d-%m-%Y")
		json.measurements do
		  json.array!(@measurements[location.id]) do |measurement|
		    json.time Time.at(measurement.observed).strftime("%H:%M:%S %P")
		    json.temp measurement.temperature
		    json.precip measurement.rainfall
		    json.wind_direction measurement.wind_dir
		    json.wind_speed measurement.wind_speed
		  end
		end
	end
end
