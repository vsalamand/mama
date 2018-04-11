require 'open-uri'

json.recipelist_name @recipe_list.name
json.recipelist_description @recipe_list.description
json.recipelist_count @recipe_list.recipes.count
json.recipelist_id @recipe_list.id
json.recipelist_type @recipe_list.recipe_list_type
json.recipes @recipe_list.recipes do |recipe|
  json.name recipe.title
  ingredients = []
    recipe.foods.each { |food| ingredients << "#{food.name.downcase}" }
  json.ingredients ingredients.join(', ')
  json.id recipe.id
  json.link recipe.link
end
