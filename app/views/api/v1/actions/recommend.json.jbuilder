require 'open-uri'

json.item_id @recommendation.id
json.recipe_id @recommendation.id
json.link card_recipe_url(@recommendation.id)
json.name @recommendation.title
# json.card cl_image_path("#{@recommendation.recipe.id}",  :format => :png,)
# json.ingredients "#{@recommendation.recipe.foods.count} ingrédients"
ingredients = []
  @recommendation.foods.each { |food| ingredients << "#{food.name.downcase}" }
json.ingredients "Ingrédients: " + ingredients.join(', ')

