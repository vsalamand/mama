require 'open-uri'

json.food @search do |array|
  food = Recipe.find(array)
  json.title food.title
  json.link food.link
  json.domain URI.parse(food.link).host
  json.tags food.tag_list
  json.id food.id
  json.servings food.servings
  ingredients = []
  food.items.order(:id).select { |item| ingredients << "#{item.ingredient.name.downcase}" }
  json.ingredients ingredients.join(', ')
end
