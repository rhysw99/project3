
json.array!(@cur_date) do
json.locations do
  json.array!(@locations) do |location|
    json.id location.location_id
    json.lat location.latitude
    json.lon location.longitude
    json.last_update location.last_update
  end
end

end
