class ApplicationController < ActionController::Base
  # ensure_security_headers
  before_action :ensure_superuser
  protect_from_forgery with: :exception

  def ensure_user
    unless current_user.present?
      session[:sandr] ||= request.url unless controller_name.match('session')
      redirect_to user_bike_index_omniauth_authorize_path and return
    end
  end

  def ensure_superuser
    ensure_user
    unless current_user && current_user.superuser?
      redirect_to root_url and return
    end
  end

  def ssl_configured?
    Rails.env.production?
  end

  private

  def after_sign_out_path_for(resource_or_scope)
    session[:aso].present? ? session.delete(:aso) : 'https://bikeindex.org'
  end

  def after_sign_in_path_for(resource_or_scope)
    session[:sandr].present? ? session.delete(:sandr) : root_url
  end
end
