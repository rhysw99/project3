require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'forecast_io'
require 'matrix'

t = Time.new
@current_time = t.getlocal
@time = current_time - (6*60*60)
@temperature = Array.new
@rainfall = Array.new
@wind_speed = Array.new
@wind_direction = Array.new
@x_data = Array.new
@forecast_temp = Array.new
@forecast_rain = Array.new
@forecast_ws = Array.new
@forecast_wd = Array.new
@probability_temp = Array.new
@probability_rain = Array.new
@probability_ws = Array.new
@probability_wd = Array.new

@latitude = :lat
@longitude = :long
@period = :period

ForecastIO.api_key = 'd8a0a48a49c54e996d85e77e8f87e03d'
ForecastIO.default_params = {units: 'si'}

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
def predictions location_id, period

  @latitude #= store latitude here
  @longitude #= store longitude here

  @period = period

  @current_time.to_i.downto(@time.to_i) do |i|
    if (current_time.to_i - i) % (10*60) == 0
      @x_data << i
      @forecast = ForecastIO.forecast(@latitude,@longitude,time: i.to_i)
      @temperature    << @forecast.currently.temperature
      @rainfall       << @forecast.currently.precipIntensity
      @wind_speed     << @forecast.currently.windSpeed
      @wind_direction << @forecast.currently.windBearing
    end
  end

  coeff_temp  = regress(@x_data, @temperature, 1)
  coeff_rain  = regress(@x_data, @rainfall, 1)
  coeff_ws    = regress(@x_data, @wind_speed, 1)
  coeff_wd    = regress(@x_data, @wind_direction, 1)


  (0..@period).step(10).each do |n|
    coeff_temp.each_with_index do |c,i|
      temp1 << c*((current_time.to_i + n*60)**i)
    end
    @forecast_temp << temp1.reduce(:+)
    @probability_temp << probability_of_success(temp1.reduce(:+))

    coeff_rain.each_with_index do |c,i|
      temp2 << c*((current_time.to_i + n*60)**i)
    end
    @forecast_rain << temp2.reduce(:+)
    @probability_rain << probability_of_success(temp2.reduce(:+))

    coeff_ws.each_with_index do |c,i|
      temp3 << c*((current_time.to_i + n*60)**i)
    end
    @forecast_ws << temp3.reduce(:+)
    @probability_ws << probability_of_success(temp3.reduce(:+))

    coefficients.each_with_index do |c,i|
      temp4 << c*((current_time.to_i + n*60)**i)
    end
    @forecast_wd << temp4.reduce(:+)
    @probability_wd << probability_of_success(temp4.reduce(:+))
  end

  @forecast_wd = Datum.getWindDirectionS(@forecast_wd)

  prediction_data = Datum.create(:temperature_predictions => @forecase_temp
                                 :temp_prob               => @probability_temp
                                 :rainfall_predictions    => @forecast_rain
                                 :rain_prob               => @probability_rain
                                 :wind_speed_predicitons  => @forecast_ws
                                 :winds_prob              => @probability_ws
                                 :wind_dir_predictions    => @forecast_wd
                                 :windd_prob              => @probability_wd)
end
