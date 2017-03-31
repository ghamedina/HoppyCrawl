class CrawlsController < ApplicationController
  before_action :set_crawl, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :landing_page, :age_verified] #maybe an except here for landing page.

  load_and_authorize_resource except: [:index, :landing_page, :age_verified, :show, :create, :map_location] #need non-admins to both create and show crawls

  # GET /crawls
  # GET /crawls.json
  def index
    @crawls = Crawl.all

    @ability = Ability.new(current_user)    # add this line

  end

  # GET /crawls/1
  # GET /crawls/1.json
  def show
  end

  # GET /crawls/new
  def new
    @crawl = Crawl.new
  end

  # GET /crawls/1/edit
  def edit
  end

  # POST /crawls
  # POST /crawls.json
  def create
    @crawl = Crawl.new
    @crawl.address = params[:address]
    @crawl.user_id = current_user.id if user_signed_in?

    respond_to do |format|
      if @crawl.save
        format.html { redirect_to @crawl, notice: 'Crawl was successfully created.' }
        format.json { render :show, status: :created, location: @crawl }
      else
        format.html { render :new }
        format.json { render json: @crawl.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /crawls/1
  # PATCH/PUT /crawls/1.json
  def update
    respond_to do |format|
      if @crawl.update(crawl_params)
        format.html { redirect_to @crawl, notice: 'Crawl was successfully updated.' }
        format.json { render :show, status: :ok, location: @crawl }
      else
        format.html { render :edit }
        format.json { render json: @crawl.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /crawls/1
  # DELETE /crawls/1.json
  def destroy
    @crawl.destroy
    respond_to do |format|
      format.html { redirect_to crawls_url, notice: 'Crawl was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def age_verified
    cookies[:accepted] = true
    redirect_to root_path
  end

  def map_location
    @crawl = Crawl.find(params[:crawl_id])
    @hash = Gmaps4rails.build_markers(@crawl) do |crawl, marker|
      marker.lat(crawl.latitude)
      marker.lng(crawl.longitude)
      marker.infowindow("<em>" + crawl.address + "</em><br>Remove this marker one day plz!!")
    end
    render json: @hash.to_json
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_crawl
      @crawl = Crawl.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def crawl_params
      params.require(:crawl).permit(:name, :address) #this won't work if show and create are not in load_and_authorize_resource
    end
end