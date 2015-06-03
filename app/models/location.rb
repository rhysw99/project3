class Location < ActiveRecord::Base
	belongs_to :postcode
	has_many :data

	def self.find_closest_to lat, long
		closest_dist = 0
		best = nil
		Location.all.each do |loc|
			puts loc
      		new_dist = Math.sqrt((long-loc.longitude)**2 + (lat-loc.latitude)**2)
      		if (new_dist < closest_dist)
        		closest_dist = new_dist
        		best = loc
      		end
    	end
    	return best
    end

end
