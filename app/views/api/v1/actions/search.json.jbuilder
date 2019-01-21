require 'open-uri'

json.results @search do |array|
  recipe = Recipe.find(array)
  json.name recipe.title
  json.link card_recipe_url(recipe.id)
  json.tags recipe.tag_list
  json.recipe_id recipe.id
  json.category recipe.category_list
  json.checklist Checklist.get_checklist(recipe.foods)
  json.emoji recipe.get_emoji
  # json.emoji "1️⃣" if @search.first == array
  # json.emoji "2️⃣" if @search[1] == array
  # json.emoji "3️⃣" if @search[2] == array
  # json.emoji "4️⃣" if @search[3] == array
  # json.emoji "5️⃣" if @search[4] == array
  # json.emoji "6️⃣" if @search[5] == array
  # json.emoji "7️⃣" if @search[6] == array
  # json.emoji "8️⃣" if @search[7] == array
  # json.emoji "9️⃣" if @search[8] == array
  # json.emoji "🔟" if @search[9] == array
  json.rank @search.index(recipe)
  json.valid_user @user
end
