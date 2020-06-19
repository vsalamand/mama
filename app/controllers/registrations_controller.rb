class RegistrationsController < Devise::RegistrationsController
  respond_to :html, :js

  after_action :remove_notice, only: [:destroy, :create]

  protected

  def after_sign_up_path_for(resource)
    # check if user sign-up using a list invite link
    if params[:shared_list].join.present?
      list = List.find(params[:shared_list].keys.first.to_i)
      Collaboration.create(list: list, user: current_user)
    else
      root_path
    end
    # root_path
  end

  private

  def remove_notice
    flash.discard(:notice)
  end
end
