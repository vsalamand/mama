class RecipeJob < ApplicationJob
  queue_as :default

  def perform(csv)
    csv.each do |row|
      data = row.to_h
      recipe = Recipe.find_by(link: data["link"])
      if recipe.present?
        puts "already in databse"
      else
        recipe = Recipe.new
        recipe.link = data["link"]
        recipe.status = "pending"
        recipe.scrape
        Item.add_recipe_items(recipe) if recipe.save?
        puts "#{recipe.title}"
      end
    end
  end
end
