require 'open-uri'

json.name @recommendations.name
json.recipe_list_name @recommendations.recipe_list.name
json.recipe_list_description @recommendations.recipe_list.description
json.count @recommendations.recipe_list.recipes.size
json.context "get_recommendations"
json.recipes @recommendations.recipe_list.recipes.each do |recipe|
  json.id recipe.id
  json.link card_recipe_url(recipe.id)
  json.name recipe.title
  json.tags recipe.tag_list
  json.category recipe.category_list
  json.checklist Checklist.get_checklist(recipe.foods)
  # json.emoji recipe.get_emoji
  json.rank @recommendations.recipe_list.recipes.index(recipe)
end
