module DataHelper

require 'matrix'

  def self.regress x, y, degree
    x_data = x.map { |xi| (0..degree).map { |pow| (xi**pow).to_f } }

    mx = Matrix[*x_data]
    my = Matrix.column_vector(y)
    ((mx.t * mx).inv * mx.t * my).transpose.to_a[0]
  end

  def self.probability_of_success forecast, key
    # probabilty = Math.exp(y_data) / (1 + Math.exp(y_data))
    # return probabilty
    return 1
  end

  #following method provides the prediction weather data
  def self.predict location, period
    current_time = Time.now.to_i
    minimum_time = current_time - (6*Constants::HOUR_IN_SECONDS)

    previous = location.data.where("observed >= :m_time AND observed <= :c_time", {:m_time => minimum_time, :c_time => current_time})

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
      wind_direction << data.getWindDirectionD
    end

    coeff = Hash.new
    forecast = Hash.new

    coeff[:temp]  = regress(time, temperature, 1)
    coeff[:rainfall]  = regress(time, rainfall, 1)
    coeff[:wind_speed]    = regress(time, wind_speed, 1)
    coeff[:wind_direction]   = regress(time, wind_direction, 1)

    equation = Array.new

    (0..period.to_i).step(10).each do |n|
      forecast[n] = Hash.new
      coeff[:temp].each_with_index do |c,i|
        equation << c*((current_time + n*Constants::MINUTE_IN_SECONDS)**i)
      end
      forecast[n][:temp] = Hash.new
      forecast[n][:temp][:value] = equation.reduce(:+).round(2)
      forecast[n][:temp][:prob] = probability_of_success(forecast, :temp)

      equation.clear

      coeff[:rainfall].each_with_index do |c,i|
        equation << c*((current_time + n*Constants::MINUTE_IN_SECONDS)**i)
      end
      forecast[n][:rain] = Hash.new
      forecast[n][:rain][:value] = equation.reduce(:+).round(2)
      forecast[n][:rain][:prob] = probability_of_success(forecast, :rain)

      equation.clear

      coeff[:wind_speed].each_with_index do |c,i|
        equation << c*((current_time + n*Constants::MINUTE_IN_SECONDS)**i)
      end
      forecast[n][:wind_speed] = Hash.new
      forecast[n][:wind_speed][:value] = equation.reduce(:+).round(2)
      forecast[n][:wind_speed][:prob] = probability_of_success(forecast, :wind_speed)

      equation.clear

      coeff[:wind_direction].each_with_index do |c,i|
        equation << c*((current_time   + n*Constants::MINUTE_IN_SECONDS)**i)
      end
      forecast[n][:wind_direction] = Hash.new
      forecast[n][:wind_direction][:value] = equation.reduce(:+).round(2)
      if (forecast[n][:wind_direction][:value] > 360)
        forecast[n][:wind_direction][:value] = forecast[n][:wind_direction][:value] - 360
      end
      forecast[n][:wind_direction][:prob] = probability_of_success(forecast, :wind_direction)
      forecast[n][:wind_direction][:value] = Datum.getWindDirectionS(forecast[n][:wind_direction][:value])
    end

    return forecast
  end

end
