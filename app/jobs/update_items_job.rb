class UpdateItemsJob < ApplicationJob
  queue_as :default

  def perform
    # Do something later
    Recipe.all.each do |recipe|
      puts recipe.title
      Item.update_recipe_items(recipe)
    end
  end
end
