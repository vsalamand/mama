class UpdateMetaRecipeListRecipesJob < ApplicationJob
  queue_as :default

  def perform
    # Do something later
    MetaRecipeList.where(list_type: "recipe").each do |mrl_recipe|
      puts mrl_recipe.name
      mrl_recipe.update_recipe
    end
  end
end
