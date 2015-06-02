require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'forecast_io'

@year = 2015
@month = 5
@day = 21
@temperature = Array.new
@rainfall = Array.new
@wind_speed = Array.new
@wind_direction = Array.new


ForecastIO.api_key = '7b1cb7b1967ffe28c939efb464835acb'
ForecastIO.default_params = {units: 'si'}


#below functions defines hourly forecast for the particular date
def hourly_forecast
  @forecast = ForecastIO.forecast(-37.7993,144.9615,time: Time.new(@year, @month, @day).to_i)
  @forecast_hist = @forecast.hourly.data.to_a

  num = @forecast_hist.size

  (0..num-1).each do |i|
    size1 = @forecast_hist.to_a[i].to_a.size
    (0..size1-1).each do |j|
      if @forecast_hist.to_a[i].to_a[j][0] == 'temperature'
        @temperature = @forecast_hist.to_a[i].to_a[j][1].to_f
      end
      if @forecast_hist.to_a[i].to_a[j][0] == 'precipIntensity'
        @rainfall << @forecast_hist.to_a[i].to_a[j][1]
      end
      if @forecast_hist.to_a[i].to_a[j][0] == 'windSpeed'
        @wind_speed << @forecast_hist.to_a[i].to_a[j][1]
      end
      if @forecast_hist.to_a[i].to_a[j][0] == 'windBearing'
        @wind_direction << @forecast_hist.to_a[i].to_a[j][1]
      end
    end
  end
end
