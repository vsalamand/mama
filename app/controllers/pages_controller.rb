class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :search, :confirmation]

  def home
  end

  def confirmation
  end

  def dashboard
    @recipes = Recipe.where(status: "published")
    @recipe_pools = RecipeList.where(recipe_list_type: "pool").sort_by { |pool| pool.recipes.count}.reverse
    @no_pool = @recipes.select { |recipe| recipe.recipe_lists.where(recipe_list_type: "pool", user_id: nil, diet_id: nil).empty? }
    @meta_recipes = MetaRecipe.all
    @mr_pools = MetaRecipeList.where(list_type: "pool").sort_by { |pool| pool.meta_recipes.count}.reverse
  end
end
