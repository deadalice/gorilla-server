class EndpointsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_endpoint!, except: [:index, :use]
  before_action :deny_endpoint!, only: [:index, :use]
  before_action :set_endpoint, except: [:index, :use]

  # GET /endpoints
  # GET /endpoints.json
  def index
    # TODO: Add group
    #@endpoints = current_user.endpoints.actual
  end

  # GET /endpoints/1
  # GET /endpoints/1.json
  def show
    @endpoint.actualize!
  end

  # GET /endpoints/1/edit
  def edit
  end

  # PATCH/PUT /endpoints/1
  # PATCH/PUT /endpoints/1.json
  def update
    respond_to do |format|
      if @endpoint.update(endpoint_params)
        format.html { redirect_to @endpoint, notice: 'Endpoint was successfully updated.' }
        format.json { render :show, status: :ok, location: @endpoint }
      else
        format.html { render :edit }
        format.json { render json: @endpoint.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /endpoints/1
  # DELETE /endpoints/1.json
  def destroy
    @endpoint.update_attribute(:authentication_token, '')
    # TODO: Do we need to keep this PC or delete it? May be it can be good to keep
    # in order to show list after login with available endpoints
    #@endpoint.discard
    sign_out current_user
    respond_to do |format|
      format.html { redirect_to endpoints_url, notice: 'Endpoint was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # PUT /endpoint/install.json
  # PUT /endpoints/1/install.json
  def install
    respond_to do |format|
      if @endpoint.install(Package.allowed_for(current_user).find(params[:id]))
        format.html { redirect_to endpoints_url, notice: 'Package soon will be installed.' }
        format.json { render :show, status: :created, location: @endpoint }
      else
        format.html { render :show }
        format.json { render json: @endpoint.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /endpoint/uninstall.json
  # PUT /endpoints/1/uninstall.json
  def uninstall
    respond_to do |format|
      if @endpoint.uninstall(Package.allowed_for(current_user).find(params[:id]))
        format.html { redirect_to endpoints_url, notice: 'Package was successfully uninstalled.' }
        format.json { render :show, status: :created, location: @endpoint }
      else
        format.html { render :show }
        format.json { render json: @endpoint.errors, status: :unprocessable_entity }
      end
    end
  end

  def use
    if request.format.json?
      generate_token(params)
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  # TODO: Differ access from API and access from web.
  # ActiveRecord::RecordNotFound only with find_by
  def set_endpoint
    if current_user.endpoint
      @endpoint = current_user.endpoint
      if rand(Rails.application.config.endpoint_token_regen_random) == 0
        @endpoint.update_attribute(:authentication_token, nil)
        current_user.endpoint_new_token = JsonWebToken.encode(@endpoint)
      end
    else
      @endpoint = current_user.endpoints.find(params[:id])
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def endpoint_params
    params.permit(:id, :name)
  end

end
