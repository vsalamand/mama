require 'open-uri'

json.item_id @recommendation.id
json.recipe_id @recommendation.recipe.id
json.link card_recipe_url(@recommendation.recipe.id)
json.name @recommendation.recipe.title.upcase
json.ingredients "📝 #{@recommendation.recipe.foods.count} ingrédients"
# json.card cl_image_path("#{@recommendation.recipe.id}",  :format => :png,)
case
  when @recommendation.recipe.rating == "excellent" then json.rating "Avis nutrition de Mama: 😋"
  when @recommendation.recipe.rating == "good" then json.rating "Avis nutrition de Mama: 🙂"
  when @recommendation.recipe.rating == "limit" then json.rating "Avis nutrition de Mama: 😕"
  when @recommendation.recipe.rating == "avoid" then json.rating "Avis nutrition de Mama: 🙁"
  else json.rating ""
end
case
  when @recommendation.recipe.tag_list.include?("rapide") then json.type "🍝 rapide"
  when @recommendation.recipe.tag_list.include?("léger") then json.type "🥕 léger"
  when @recommendation.recipe.tag_list.include?("snack") then json.type "🍔 snack"
  when @recommendation.recipe.tag_list.include?("tarte salée") then json.type "🍕 tarte salée"
  when @recommendation.recipe.tag_list.include?("gourmand") then json.type "🍽️ gourmand"
end
