class RegistrationsController < Devise::RegistrationsController

  protected

  def after_sign_up_path_for(resource)
    thank_you_path
  end
end
