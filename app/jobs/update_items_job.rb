class UpdateItemsJob < ApplicationJob
  queue_as :default

  def perform
    # Do something later
    Recipe.all.each do |recipe|
      puts recipe.title
      Item.update_recipe_items(recipe)
      sleep(12.0/24.0)
    end
  end
end
