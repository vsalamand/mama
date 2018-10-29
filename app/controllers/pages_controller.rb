class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :search, :confirmation]

  def home
  end

  def confirmation
  end

  def dashboard
    @recipes = Recipe.where(status: "published")
    @recipe_pools = RecipeList.where(recipe_list_type: "pool")
    @meta_recipes = MetaRecipe.all
    @mr_pools = MetaRecipeList.where(recipe_list_type: "pool")
  end
end
