class EndpointsController < ApplicationController
  before_action :authenticate_user!
  before_action :deny_endpoint!, only: [:index, :create, :update]
  before_action :set_endpoint, except: [:index, :create, :update]

  # GET /endpoints
  # GET /endpoints.json
  def index
    # TODO: Add group
    @endpoints = current_user.endpoints.actual
  end

  # GET /endpoints/1
  # GET /endpoints/1.json
  def show
  end

  # POST /endpoints.json
  def create
    respond_to do |format|
      format.html { redirect_to endpoints_url }
      format.json { generate_token(endpoint_params.to_hash.with_indifferent_access) }
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

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_endpoint
    if current_user.endpoint
      @endpoint = current_user.endpoint
      if rand(Rails.application.config.endpoint_token_regen_random) == 0
        @endpoint.update_attribute(:authentication_token, nil)
        current_user.endpoint_new_token = JsonWebToken.encode(@endpoint)
      end
    else
      head :unauthorized
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def endpoint_params
    params.require(:endpoint).permit(:id, :name)
  end

end
