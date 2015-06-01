json.array!(@postcodes) do |postcode|
  json.extract! postcode, :id, :postcode, :name, :latitude, :longitude
  json.url postcode_url(postcode, format: :json)
end
