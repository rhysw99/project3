module LocationsHelper

  def self.getPostcodeFromLatLong(lat, long)
    postcodes = Postcode.all

    closest_dist = Float::MAX
    best_postcode = 0

    postcodes.each do |postcode|
      new_dist = Math.sqrt((long-postcode.longitude)**2 + (lat-postcode.latitude)**2)
      if (new_dist < closest_dist)
        closest_dist = new_dist
        best_postcode = postcode.postcode
      end
    end
    return best_postcode

  end
end
