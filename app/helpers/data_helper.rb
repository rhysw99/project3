module DataHelper

def regress x, y, degree
  x_data = x.map { |xi| (0..degree).map { |pow| (xi**pow).to_f } }

  mx = Matrix[*x_data]
  my = Matrix.column_vector(y)
  ((mx.t * mx).inv * mx.t * my).transpose.to_a[0]
end

def probability_of_success y_data
  probabilty = Math.exp(y_data) / (1 + Math.exp(y_data))
  return probabilty
end

#following method provides the prediction weather data
def predictions location, period
  current_time = Time.now
  minimum_time = current_time - (6*CONSTANTS::HOUR_IN_SECONDS)

  previous = location.data.where("time >= :m_time AND time <= :c_time", {:m_time => minimum_time, :c_time => current_time})

  time = Array.new
  temperature = Array.new
  rainfall = Array.new
  wind_speed = Array.new
  wind_direction = Array.new

  previous.each do |data|
    time << data.observed
    temperature << data.temperature
    rainfall << data.rainfall
    wind_speed << data.wind_speed
    wind_direction << data.windSpeedInD
  end

  coeff = Hash.new
  probability = Hash.new
  forecast = Hash.new

  coeff[:temp]  = regress(time, temperature, 1)
  coeff[:rainfall]  = regress(time, rainfall, 1)
  coeff[:wind_speed]    = regress(time, wind_speed, 1)
  coeff[:wind_dir]   = regress(time, wind_direction, 1)

  equation = Array.new


  (0..period).step(10).each do |n|
    forecast[n] = Hash.new
    coeff[:temp].each_with_index do |c,i|
      equation << c*((current_time.to_i + n*CONSTANTS::MINUTE_IN_SECONDS)**i)
    end
    forecast[n][:temperature] = equation.reduce(:+)
    probability[n][:temperature] = probability_of_success(forecast, :temperature)

    equation.clear

    coeff[:rainfall].each_with_index do |c,i|
      equation << c*((current_time.to_i + n*CONSTANTS::MINUTE_IN_SECONDS)**i)
    end
    forecast[n][:rainfall] = equation.reduce(:+)
    probability[n][:rainfall] = probability_of_success(forecast, :rainfall)

    equation.clear

    coeff[:wind_speed].each_with_index do |c,i|
      equation << c*((current_time.to_i + n*CONSTANTS::MINUTE_IN_SECONDS)**i)
    end
    forecast[n][:wind_speed] = equation.reduce(:+)
    probability[n][:wind_speed] = probability_of_success(forecast, :wind_speed)

    equation.clear

    coeff[:wind_direction].each_with_index do |c,i|
      equation << c*((current_time.to_i + n*CONSTANTS::MINUTE_IN_SECONDS)**i)
    end
    forecast[n][:wind_direction] = equation.reduce(:+)
    if (forecast[n][:wind_direction] > 360)
      forecast[n][:wind_direction] = forecast[n][:wind_direction] - 360
    end
    probability[n][:wind_direction] = probability_of_success(forecast, :wind_direction)
  end

  predictions = Hash.new
  predictions[:forecast] = forecast
  predictions[:probability] = probability

  return predictions
end

end
