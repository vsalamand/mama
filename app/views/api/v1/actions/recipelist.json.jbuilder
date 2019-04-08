require 'open-uri'

json.recipelist_name @recipe_list.name
json.recipelist_description @recipe_list.description
json.recipelist_count @recipe_list.recipes.count
json.recipelist_id @recipe_list.id
json.recipelist_type @recipe_list.recipe_list_type
json.recipes @recipe_list.recipe_list_items[-10, 10].reverse.each do |item|
  json.name item.recipe.title.upcase
  # ingredients = []
  #   item.recipe.foods.each { |food| ingredients << "#{food.name.downcase}" }
  # json.ingredients ingredients.join(', ')
  json.ingredients "#{item.recipe.foods.count} ingrédients"
  case
    when item.recipe.rating == "excellent" then json.rating "💖 que des aliments recommandés !"
    when item.recipe.rating == "good" then json.rating "💚 bon avec peu d'aliments à modérer"
    when item.recipe.rating == "limit" then json.rating "💛 avec des aliments à limiter"
    when item.recipe.rating == "avoid" then json.rating "❤️ uniquement des aliments à éviter"
    else json.rating ""
  end
  json.id item.recipe.id
  json.link item.recipe.link
end
