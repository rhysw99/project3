json.array!(@data) do |datum|
  json.extract! datum, :id, :location_id, :rainfall, :temperature, :wind_dir, :wind_speed, :observed
  json.url datum_url(datum, format: :json)
end
