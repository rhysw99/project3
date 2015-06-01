# This file is NOT designed to be executed.
# It simply is a file to store all the transforms/tags of each source if we need to modify them.

##################################

# Source 2, Forecast.io API
# Transforms
'lambda {
data[i][:location_id] = location.id;
data[i][:observationTime] = forecast["currently"]["time"];
data[i][:temperature] = forecast["currently"]["temperature"];
data[i][:windSpeed] = forecast["currently"]["windSpeed"];
data[i][:windDirection] = forecast["currently"]["windBearing"];
data[i][:rainfall] = forecast["currently"]["precipIntensity"];

compass = {0.0 => "N", 22.5=>"NNE", 45.0=>"NE", 67.5=>"ENE", 90.0=>"E", 112.5=>"ESE", 135.0=>"SE", 157.5=>"SSE", 180.0=>"S", 202.5=>"SSW", 225.0=>"SW", 247.5=>"WSW", 270.0=>"W", 292.5=>"WNW", 315.0=>"NW", 337.5=>"NNW", 360.0=>"N"};
data[i][:windDirection] = compass[(data[i][:windDirection]/22.5).round*22.5];

prev_obs = WeatherDatum.retrieve_previous_record(source.id, station.id);
current_time = Time.at(data[i][:observationTime]).utc.in_time_zone(Constants::TIME_ZONE); # Current observation time (AEST)

# If we have started a new day.
if (prev_obs.blank? || (prev_obs.time_in_local_timezone(Constants::TIME_ZONE).hour < 9 && current_time.hour >= 9))
  # Starting new day.
  time_since_9am = (data[i][:observationTime] - current_time.change(:hour=>9, :min=>0, :sec=>0).to_i).to_f/Constants::HOUR_IN_SECONDS;

  data[i][:rainfall] = time_since_9am*data[i][:rainfall];
else
  # Add rainfall since last update to current daily tally.
  prev_time = prev_obs.observationTime.to_i;
  time_since_last_observation = (data[i][:observationTime] - prev_time).to_f/Constants::HOUR_IN_SECONDS;
  data[i][:rainfall] = prev_obs.rainfall + data[i][:rainfall] * time_since_last_observation;
end
data[i][:rainfall] = data[i][:rainfall].round(4) }'
