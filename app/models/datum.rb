class Datum < ActiveRecord::Base
	@compass = {0.0 => "N", 22.5=>"NNE", 45.0=>"NE", 67.5=>"ENE", 90.0=>"E", 112.5=>"ESE", 135.0=>"SE", 157.5=>"SSE", 180.0=>"S", 202.5=>"SSW", 225.0=>"SW", 247.5=>"WSW", 270.0=>"W", 292.5=>"WNW", 315.0=>"NW", 337.5=>"NNW", 360.0=>"N"};

  def getWindDirectionS windDirection
		return @compass[(windDirection/22.5).round*22.5];
	end

	def getWindDirectionD windDirection
		return @compass.key(windDirection)
	end

end
