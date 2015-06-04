class Datum < ActiveRecord::Base

  	def getWindDirectionS
  		compass = {0.1 => "CALM", 0.0 => "N", 22.5=>"NNE", 45.0=>"NE", 67.5=>"ENE", 90.0=>"E", 112.5=>"ESE", 135.0=>"SE", 157.5=>"SSE", 180.0=>"S", 202.5=>"SSW", 225.0=>"SW", 247.5=>"WSW", 270.0=>"W", 292.5=>"WNW", 315.0=>"NW", 337.5=>"NNW", 360.0=>"N"};
		return compass[(wind_dir/22.5).round*22.5]
	end

	def getWindDirectionD
		compass = {0.1 => "CALM", 0.0 => "N", 22.5=>"NNE", 45.0=>"NE", 67.5=>"ENE", 90.0=>"E", 112.5=>"ESE", 135.0=>"SE", 157.5=>"SSE", 180.0=>"S", 202.5=>"SSW", 225.0=>"SW", 247.5=>"WSW", 270.0=>"W", 292.5=>"WNW", 315.0=>"NW", 337.5=>"NNW", 360.0=>"N"};
		return compass.key(wind_dir)
	end

	def self.getWindDirectionS wind_dir
		compass = {0.1 => "CALM", 0.0 => "N", 22.5=>"NNE", 45.0=>"NE", 67.5=>"ENE", 90.0=>"E", 112.5=>"ESE", 135.0=>"SE", 157.5=>"SSE", 180.0=>"S", 202.5=>"SSW", 225.0=>"SW", 247.5=>"WSW", 270.0=>"W", 292.5=>"WNW", 315.0=>"NW", 337.5=>"NNW", 360.0=>"N"};
		return compass[(wind_dir/22.5).round*22.5]
	end

	def self.getWindDirectionD wind_dir
		compass = {0.1 => "CALM", 0.0 => "N", 22.5=>"NNE", 45.0=>"NE", 67.5=>"ENE", 90.0=>"E", 112.5=>"ESE", 135.0=>"SE", 157.5=>"SSE", 180.0=>"S", 202.5=>"SSW", 225.0=>"SW", 247.5=>"WSW", 270.0=>"W", 292.5=>"WNW", 315.0=>"NW", 337.5=>"NNW", 360.0=>"N"};
		return compass.key(wind_dir)
	end

end
