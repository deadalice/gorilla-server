class ApplicationController < ActionController::Base
  include ApplicationHelper
  include Pagy::Backend

  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :api_check_headers, if: -> { request.format.json? }
  before_action :set_locale

  protected

  def api_check_headers
    reset_session
    if service_keys.include?(request.headers['X-API-Service']) ||
         Rails.env.development?
      if request.headers['X-API-Token']
        unless payload = JsonWebToken.decode(request.headers['X-API-Token'])
          return true
        end
        case payload[:scope]
        when Endpoint.name
          # TODO: Cache endpoint
          endpoint, user = cached_endpoint_user(payload[:uuid], payload[:token])
          unless endpoint.nil? || user.nil?
            sign_in(user)
            current_user.endpoint = endpoint
            # TODO: Store request.remote_ip
          else
            puts "!!!!! BLOCK !!!!! #{payload[:uuid]}|#{payload[:token]}"
            # TODO: Endpoint.find_by(id: payload[:uuid])&.block! reason: "#{payload[:uuid]}|#{payload[:token]}"
          end
        when User.name
          if user = cached_user(payload[:uuid], payload[:token])
            sign_in(user)
          end
        end
      end
    elsif anonymous_keys.include?(request.headers['X-API-Service'])
      return true
    else
      head :upgrade_required
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username name locale])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username name locale])
  end

  def set_locale
    if current_user.nil?
      I18n.locale = session[:locale] ||
        http_accept_language.compatible_language_from(I18n.available_locales) ||
        I18n.default_locale.to_s
      session[:locale] = I18n.locale
    else
      I18n.locale = current_user.locale
    end
  end

  # TODO: To check license
  #User.find_by(email: request.headers['X-User-Email']).endpoints.size <= MAXIMUM
end
