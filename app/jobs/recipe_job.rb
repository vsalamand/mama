class RecipeJob < ApplicationJob
  queue_as :default

  def perform
    Recipe.reindex
    recipes = Recipe.where(status: "published")
    recipes.each do |recipe|
      recipe.meta_recipe_lists.first.tag_recipe
      recipe.add_to_pool
      recipe.seasonal?
      # recipe.rate
    end
  end
end
