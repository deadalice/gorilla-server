module ApplicationHelper
  include Pagy::Frontend

  def alert_for(flash_type)
    {
      success: "alert-success",
      error: "alert-danger",
      alert: "alert-warning",
      notice: "alert-info",
    }[
      flash_type.to_sym
    ] || flash_type.to_s
  end

  def title(object)
    if object.is_a? Package
      (object.user == current_user) ? object.name :
        "#{object.user.username}/#{object.name}"
    end
  end

  def cache_fetch(model, id, token)
    Rails.cache.fetch(
      "#{model.name}_#{id}",
      expires_in: MODEL_CACHE_TIMEOUT,
    ) do
      model.find_by(
        id: id,
        authentication_token: token,
        blocked_at: nil,
      )
    end
  end

  def cached_endpoint(id, token)
    @_cached_endpoint ||= cache_fetch(Endpoint, id, token)
  end

  def cached_user(id, token)
    @_cached_user ||= cache_fetch(User, id, token)
  end

  def current_endpoint
    @_cached_endpoint
  end

  def sign_in_endpoint(endpoint)
    endpoint.reset_token
    @_cached_endpoint ||= endpoint
  end

  def render_errors(errors, status:)
    if errors.is_a? Array
      render json: { errors: errors }, status: status
    else
      render json: { error: errors }, status: status
    end
  end
end
