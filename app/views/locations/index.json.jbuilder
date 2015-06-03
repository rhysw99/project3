json.extract! @cur_date, :date
json.locations do
  json.array!(@locations) do |location|
    json.id location.location_id
    json.lat location.latitude
    json.lon location.longitude
    json.last_update Time.at(location.last_update).strftime("%H:%M%P %d-%m-%Y")
  end
end
