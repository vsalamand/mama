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
  food.items.order(:id).select { |item| ingredients << "#{item.food.name.downcase}" }
  json.ingredients ingredients.join(', ')
  json.emoji "1️⃣" if @search.first == array
  json.emoji "2️⃣" if @search[1] == array
  json.emoji "3️⃣" if @search[2] == array
  json.emoji "4️⃣" if @search[3] == array
  json.emoji "5️⃣" if @search[4] == array
  json.emoji "6️⃣" if @search[5] == array
  json.emoji "7️⃣" if @search[6] == array
  json.emoji "8️⃣" if @search[7] == array
  json.emoji "9️⃣" if @search[8] == array
  json.emoji "🔟" if @search[9] == array
  json.rank @search.index(food)
  json.valid_user @user
end
