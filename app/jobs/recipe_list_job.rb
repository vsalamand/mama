class RecipeListJob < ApplicationJob
  queue_as :default

  def perform
    Recipe.reindex
    RecipeList.update_recipe_pools
  end
end
