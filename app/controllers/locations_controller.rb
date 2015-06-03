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
    @location = Location.find_by(location_id: params[:location_id])
    @cur_date = {:date => Time.now.strftime("%d-%m-%Y")}
    within_30_mins = Time.now.to_i - Constants::HOUR_IN_SECONDS/2
    latest_update = @location.data.where("observed >= :time", {:time=>within_30_mins}).last
    if (!latest_update.nil?) 
      current_temp = latest_update.temperature
      current_condition = "Sunny" # NO idea what to do for this
    else
      current_temp = "nil"
      current_condition = "nil" # NO idea what to do for this
    end

    @current = {:temp=>current_temp, :condition =>current_condition}

    min_time = Time.parse(params[:date]).to_i
    max_time = min_time + Constants::HOUR_IN_SECONDS*24
    @measurements = @location.data.where("observed >= :min_time AND observed < :max_time", {:min_time=>min_time, :max_time=>max_time})
  end

  # GET /weather/data/:post_code/:date
  # GET /weather/data/:post_code/:date.json
  def show_by_postcode
    params = location_params
    postcode = Postcode.find_by(postcode: params[:post_code])
    @locations = postcode.locations
    @measurements = Hash.new
    @cur_date = {:date => Time.now.strftime("%d-%m-%Y")}
    min_time = Time.parse(params[:date]).to_i
    max_time = min_time + Constants::HOUR_IN_SECONDS*24
    @locations.each do |loc|
      @measurements[loc.id] = loc.data.where("observed >= :min_time AND observed < :max_time", {:min_time=>min_time, :max_time=>max_time})
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find_by location_id: params[:location_id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.permit(:location_id, :latitude, :longitude, :last_update, :post_code, :date)
    end
end
