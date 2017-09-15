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

  def suggest
    @suggestions = []
    @suggestions << starter = Recipe.search("entrée snack", operator: "or", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
    @suggestions << light_dish = Recipe.search("accompagnement", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
    @suggestions << main_dish = Recipe.search("plat", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
    @suggestions << dessert = Recipe.search("dessert", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
  end
end
