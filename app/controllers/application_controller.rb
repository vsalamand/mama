class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  # rescue_from StandardError do |exception|
  #   # render what you want here
  #   # flash[:alert] = 'Oups une erreur est survenue...'
  #   redirect_to root_path
  # end

  def after_sign_in_path_for(resource)
    @lists = current_user.lists.saved + current_user.shared_lists

    if @lists.any?
      return list_path(@lists.first)
    else
      return root_path
    end
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

