require 'open-uri'

json.context "search"
json.results @search do |array|
  recipe = Recipe.find(array)
  json.name recipe.title
  json.link recipe.link.blank? ? card_recipe_url(recipe.id) : recipe.link
  json.tags recipe.tag_list
  json.recipe_id recipe.id
  json.category recipe.category_list
  json.checklist Checklist.get_checklist(recipe.foods)
  # json.emoji recipe.get_emoji
  json.rank @search.index(recipe)
  json.valid_user @user
end
