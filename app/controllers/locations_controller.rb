class LocationsController < ApplicationController

  # GET /locations
  # GET /locations.json
  def index
    @locations = Location.all
    @cur_date = {:date => Time.now.strftime("%d-%m-%Y")}
  end

end
