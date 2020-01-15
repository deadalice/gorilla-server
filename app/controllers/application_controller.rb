class ApplicationController < ActionController::Base
  include ApplicationHelper

  before_action :check_headers, if: -> { !devise_controller? && request.format.json? }
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def check_headers
    if (request.headers['X-API-Version'] != Rails.application.config.api_version)
      render json: {
        version: Rails.application.config.api_version,
        event: 'E_API_VERSION',
        error: I18n.t(' wrong version ')
      }, status: :forbidden
    elsif (request.headers['X-API-Service'] != service_key(Rails.application.config.service_path))
      # TODO: Check this from allowed list including
      render json: {
        version: Rails.application.config.api_version,
        event: 'E_FILE_VERSION',
        error: I18n.t(' wrong requester '),
        url: Rails.application.config.service_path
      }, status: :forbidden
    else
      @endpoint = Endpoint.find_by(key: request.headers['X-API-Endpoint'], authentication_token: request.headers['X-API-Token'])
      if @endpoint&.user
        bypass_sign_in(@endpoint.user)
        # TODO: Find a better place to store endpoint data
        session[:endpoint] = @endpoint
      else
        render json: {
          version: Rails.application.config.api_version,
          event: 'E_SESSION_TOKEN',
          error: I18n.t(' missing keys ')
        }, status: :unauthorized
      end
    end

    # TODO: To check license
    #User.find_by(email: request.headers['X-User-Email']).endpoints.size <= MAXIMUM
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end
end
