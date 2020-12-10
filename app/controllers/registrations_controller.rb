class RegistrationsController < Devise::RegistrationsController
  respond_to :html, :js

  after_action :remove_notice, only: [:destroy, :create]

  protected

  def after_sign_up_path_for(resource)
    # check signup context
    if params[:user][:context].present?
      if params[:user][:context] == "favorites"
        @context = "favorites"
      elsif params[:user][:context] !~ /\D/
        recipe = Recipe.find(params[:user][:context])
        recipe.add_to_favorites(current_user) if recipe.present?
        @context = "favorites"
      end
    # check if user sign-up using a list invite link
    elsif params[:shared_list].present?
      if params[:shared_list].first.present?
       if params[:shared_list].keys.first.to_i > 0
          list = List.find(params[:shared_list].keys.first.to_i)
          Collaboration.create(list: list, user: current_user)
          root_path
        else
          root_path
        end
      else
        root_path
      end
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
