class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :resource_name, :resource, :devise_mapping, :resource_class, :current_list, :current_recipe_list


  def current_list
    if current_user
      @list = current_user.get_assistant
    else
      # session[:list] = nil
      if session[:list]
        @list = List.find(session[:list])
      else
        @list = List.where("created_at < ?", 2.days.ago).where(name: "Assistant", status: "temporary", list_type: "assistant", sorted_by: "rayon").first
        if @list.nil?
          @list = List.create(name: "Assistant", status: "temporary", list_type: "assistant", sorted_by: "rayon")
        else
          @list.items.destroy_all
        end
        session[:list] = @list.id
        return @list
      end
    end
  end

  def current_recipe_list
    if current_user
      @recipe_list = current_user.get_latest_recipe_list
    else
      # session[:recipe_list] = nil
      if session[:recipe_list]
        @recipe_list = RecipeList.find(session[:recipe_list])
      else
        @recipe_list = RecipeList.where("created_at < ?", 2.days.ago).where(status: "temporary", recipe_list_type: "personal").first
        if @recipe_list.nil?
          @recipe_list = RecipeList.create(status: "temporary", recipe_list_type: "personal")
        else
          @recipe_list.recipe_list_items.destroy_all
        end
        session[:recipe_list] = @recipe_list.id
        return @recipe_list
      end
    end
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def resource_class
    User
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
  # rescue_from StandardError do |exception|
  #   # render what you want here
  #   # flash[:alert] = 'Oups une erreur est survenue...'
  #   redirect_to root_path
  # end

  def after_sign_in_path_for(resource)
    if params[:user][:context].present?
      if params[:user][:context] == "favorites"
        @context = "favorites"
      elsif params[:user][:context] !~ /\D/
        recipe = Recipe.find(params[:user][:context])
        recipe.add_to_favorites(current_user) if recipe.present?
        @context = "favorites"
      end
    else
      @context = ""
      root_path
    end
    # @lists = current_user.lists.saved + current_user.shared_lists

    # if @lists.any?
    #   return list_path(@lists.last)
    # else
    #   return root_path
    # end
  end

  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end


  protected

  def authenticate_admin!
    authenticate_user!
    redirect_to root_path, status: :forbidden unless current_user.admin?
  end

  def configure_permitted_parameters
    attributes = [:email, :username]
    devise_parameter_sanitizer.permit(:sign_up, keys: attributes)
    devise_parameter_sanitizer.permit(:account_update, keys: attributes)
  end

  # def configure_permitted_parameters
  #   # For additional fields in app/views/devise/registrations/new.html.erb
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:email])

  #   # For additional in app/views/devise/registrations/edit.html.erb
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:email])

  #   # For additional fields in app/views/devise/session/new.html.erb
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:email])
  # end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end


end

