require 'open-uri'

json.food @suggestions do |array|
  array.each do |food|
    json.title food.title
    json.link food.link
    json.domain URI.parse(food.link).host
    json.tags food.tag_list
    json.id food.id
    json.servings food.servings
    ingredients = []
    food.items.order(:id).select { |item| ingredients << "#{item.ingredient.name.downcase}" }
    json.ingredients ingredients.join(', ')
    json.emoji "❤️" if food.tag_list.include?("équilibré")
    json.emoji "💛" if food.tag_list.include?("rapide")
    json.emoji "💚" if food.tag_list.include?("léger")
    json.emoji "💙" if food.tag_list.include?("snack")
    json.emoji "💜" if food.tag_list.include?("gourmand")
  end
end
