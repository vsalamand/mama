class RegistrationsController < Devise::RegistrationsController
  after_action :remove_notice, only: [:destroy, :create]

  protected

  def after_sign_up_path_for(resource)
    # check if user sign-up using a list invite link
    if params[:shared_list].join.present?
      list = List.find(params[:shared_list].keys.first.to_i)
      Collaboration.create(list: list, user: current_user)
    end
    root_path
  end

  private

  def remove_notice
    flash.discard(:notice)
  end
end
