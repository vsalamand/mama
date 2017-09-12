class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :search]

  def home
  end

  def search
    search = params[:query].present? ? params[:query] : nil
    @recipes = if search
      Recipe.search(search)
    end
  end
end
