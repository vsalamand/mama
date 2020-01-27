class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from Exception, with: :not_found
  rescue_from ActionController::RoutingError, with: :not_found

  def raise_not_found
    raise ActionController::RoutingError.new("No route matches #{params[:unmatched_route]}")
  end

  def not_found
    redirect_to root_path
    # respond_to do |format|
    #   format.html { render file: "#{Rails.root}/public/404", layout: false, status: :not_found }
    #   format.xml { head :not_found }
    #   format.any { head :not_found }
    # end
  end

  def error
    redirect_to root_path
    # respond_to do |format|
    #   format.html { render file: "#{Rails.root}/public/500", layout: false, status: :error }
    #   format.xml { head :not_found }
    #   format.any { head :not_found }
    # end
  end

  protected

  def authenticate_admin!
    authenticate_user!
    redirect_to root_path, status: :forbidden unless current_user.admin?
  end

  def configure_permitted_parameters
    attributes = [:email]
    devise_parameter_sanitizer.permit(:sign_up, keys: attributes)
    devise_parameter_sanitizer.permit(:account_update, keys: attributes)
  end

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:email])

    # For additional fields in app/views/devise/session/new.html.erb
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email])
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

end
