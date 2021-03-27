class ApplicationController < ActionController::Base
  include ApplicationHelper
  include Pagy::Backend
  include Pundit
  include ApiKeys

  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :api_check_headers, if: -> { request.format.json? }
  before_action :set_locale

  protected

  def api_check_headers
    service = request.headers["X-API-Service"]
    if request.headers["X-API-Token"]
      if payload = JsonWebToken.decode(request.headers["X-API-Token"])
        scope = payload[:scope]
        uuid = payload[:uuid]
        token = payload[:token]
      else
        return false
      end
    end

    if (scope == Endpoint.name) && ApiKeys.endpoint.include?(service)
      if endpoint = cached_endpoint(uuid, token)
        rand(ENDPOINT_TOKEN_REGEN_RANDOM) == 0 ? endpoint.reset_token : endpoint.touch
      else
        # Block endpoint with old token for security reasons
        Endpoint.active.find_by(id: uuid)&.block!(
          reason: "api_check_headers #{uuid} #{token}",
        )
        render_errors I18n.t("devise.failure.blocked"), status: :unauthorized
      end
    elsif (scope == User.name) && ApiKeys.user.include?(service)
      if user = cached_user(uuid, token)
        sign_in user
      else
        render_errors I18n.t("devise.failure.blocked"), status: :unauthorized
      end
    elsif ApiKeys.anonymous.include?(service)
      return true
    elsif service
      head :upgrade_required
    else
      head :forbidden
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username name locale])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username name locale])
  end

  def set_locale
    session[:locale] ||= current_endpoint&.locale ||
                         current_user&.locale ||
                         http_accept_language.compatible_language_from(I18n.available_locales) ||
                         I18n.default_locale.to_s
    I18n.locale = session[:locale]
  end

  # TODO: To check license
  #User.find_by(email: request.headers['X-User-Email']).endpoints.size <= MAXIMUM
end
