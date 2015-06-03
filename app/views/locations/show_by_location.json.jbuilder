json.extract! @cur_date, :date
json.extract! @current, :temp, :condition
json.measurements do
  json.array!(@measurements) do |measurement|
    json.time Time.at(measurement.observed).strftime("%H:%M:%S %P")
    json.temp measurement.temperature
    json.precip measurement.rainfall
    json.wind_direction measurement.wind_dir
    json.wind_speed measurement.wind_speed
  end
end
