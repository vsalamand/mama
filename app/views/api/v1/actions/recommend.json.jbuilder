require 'open-uri'

json.item_id @recommendation.id
json.recipe_id @recommendation.recipe.id
json.link @recommendation.recipe.link
json.name @recommendation.recipe.title.upcase
json.ingredients "📝 #{@recommendation.recipe.foods.count} ingrédients"
case
  when @recommendation.recipe.rating == "excellent" then json.rating "💖 que des aliments recommandés !"
  when @recommendation.recipe.rating == "good" then json.rating "💚 bon avec peu d'aliments à modérer"
  when @recommendation.recipe.rating == "limit" then json.rating "💛 contient des aliments à limiter"
  when @recommendation.recipe.rating == "avoid" then json.rating "❤️ ne contient que des aliments à limiter"
  else json.rating ""
end
case
  when @recommendation.recipe.tag_list.include?("rapide") then json.type "🍝 rapide"
  when @recommendation.recipe.tag_list.include?("léger") then json.type "🥕 léger"
  when @recommendation.recipe.tag_list.include?("snack") then json.type "🍔 snack"
  when @recommendation.recipe.tag_list.include?("tarte salée") then json.type "🍕 tarte salée"
  when @recommendation.recipe.tag_list.include?("snack") then json.type "🍽️ snack"
end
