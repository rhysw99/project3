class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  # GET /locations
  # GET /locations.json
  def index
    @locations = Location.all
    @cur_date = {:date => Time.now.strftime("%d-%m-%Y")}
  end

  # GET /weather/data/:location_id/:date
  # GET /weather/data/:location_id/:date.json
  def show_by_location
    params = location_params
    @location = Location.find_by location_id: params[:location_id]
    @measurements = Datum.find_by id: @location.id
    @cur_date = {:date => Time.now.strftime("%d-%m-%Y")}
    # TODO: Check for measurement within last 30 minutes, set current temperature
    if (updateWithinLast30Minutes) 
      @current_temp = getMostRecentTemperature
    else
      @current_temp = nil
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.permit(:location_id, :latitude, :longitude, :last_update, :postcode)
    end
end
