require 'open-uri'

json.id @recipe.id
json.title @recipe.title
json.servings @recipe.servings
json.ingredients @recipe.ingredients
json.instructions @recipe.instructions
json.origin @recipe.origin
json.link @recipe.link
json.items @recipe.items.each do |item|
  if item.food.present?
    json.id item.id
    json.recipe_ingredient item.name
    json.food_id  item.food_id
    json.quantity item.quantity
    json.unit_id  item.unit_id
    json.food_name item.food.name
  end
end
