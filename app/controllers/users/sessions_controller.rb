# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :html, :js

  after_action :remove_notice, only: [:destroy, :create]
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    resource = User.find_for_database_authentication(email: params[:user][:email])
    if resource.valid_password?(params[:user][:password])
      super
    else
      render 'new.js.erb'
      ahoy.track 'invalid login'
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  private

  def remove_notice
    flash.discard(:notice)
  end
end
