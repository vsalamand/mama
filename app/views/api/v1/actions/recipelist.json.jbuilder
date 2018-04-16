require 'open-uri'

json.recipelist_name @recipe_list.name
json.recipelist_description @recipe_list.description
json.recipelist_count @recipe_list.recipes.count
json.recipelist_id @recipe_list.id
json.recipelist_type @recipe_list.recipe_list_type
json.recipes @recipe_list.recipe_list_items[-10, 10].each do |item|
  json.name item.recipe.title
  ingredients = []
    item.recipe.foods.each { |food| ingredients << "#{food.name.downcase}" }
  json.ingredients ingredients.join(', ')
  json.id item.recipe.id
  json.link item.recipe.link
end
