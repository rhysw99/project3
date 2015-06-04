json.extract! @location, :location_id
json.predictions do
	json.array!(@predictions) do |time, prediction|
		json.time time
		json.array!(prediction) do |type, values|
			json.set! type do
			  json.time (Time.now + time*Constants::MINUTE_IN_SECONDS).strftime("%H:%M%P %d-%m-%Y")
			  json.value values[:value]
			  json.probability values[:prob]
			end
		end
	end
end
