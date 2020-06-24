class RecipeJob < ApplicationJob
  queue_as :default

  def perform(csv)
    csv.each do |row|
      data = row.to_h
      if Recipe.find_by(link: data["link"]).nil?
        recipe = Recipe.new
        recipe.link = data["link"]
        recipe.status = "pending"
        recipe.scrape
        Item.add_recipe_items(recipe) if recipe.save
        puts "#{recipe.link}"
      end
    end
  end
end
