class PostcodesController < ApplicationController
  before_action :set_postcode, only: [:show, :edit, :update, :destroy]

  # GET /postcodes
  # GET /postcodes.json
  def index
    @postcodes = Postcode.all
  end

  # GET /postcodes/1
  # GET /postcodes/1.json
  def show
  end

  # GET /postcodes/new
  def new
    @postcode = Postcode.new
  end

  # GET /postcodes/1/edit
  def edit
  end

  # POST /postcodes
  # POST /postcodes.json
  def create
    @postcode = Postcode.new(postcode_params)

    respond_to do |format|
      if @postcode.save
        format.html { redirect_to @postcode, notice: 'Postcode was successfully created.' }
        format.json { render :show, status: :created, location: @postcode }
      else
        format.html { render :new }
        format.json { render json: @postcode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /postcodes/1
  # PATCH/PUT /postcodes/1.json
  def update
    respond_to do |format|
      if @postcode.update(postcode_params)
        format.html { redirect_to @postcode, notice: 'Postcode was successfully updated.' }
        format.json { render :show, status: :ok, location: @postcode }
      else
        format.html { render :edit }
        format.json { render json: @postcode.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /postcodes/1
  # DELETE /postcodes/1.json
  def destroy
    @postcode.destroy
    respond_to do |format|
      format.html { redirect_to postcodes_url, notice: 'Postcode was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def postcode_predictions
  
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_postcode
      @postcode = Postcode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def postcode_params
      params.require(:postcode).permit(:postcode, :name, :latitude, :longitude)
    end
end
