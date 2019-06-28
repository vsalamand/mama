class MetaRecipeItemsJob < ApplicationJob
  queue_as :default

  def perform
    # Do something later
    MetaRecipe.all.each do |meta_recipe|
      puts meta_recipe.name
      MetaRecipeItem.update_meta_recipe_items(meta_recipe)
    end
  end
end
