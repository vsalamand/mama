class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?


  protected

  def authenticate_admin!
    authenticate_user!
    redirect_to root_path, status: :forbidden unless current_user.admin?
  end

  def configure_permitted_parameters
    attributes = [:username, :email]
    devise_parameter_sanitizer.permit(:sign_up, keys: attributes)
    devise_parameter_sanitizer.permit(:account_update, keys: attributes)
  end

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :email])

    # For additional fields in app/views/devise/session/new.html.erb
    devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

end
