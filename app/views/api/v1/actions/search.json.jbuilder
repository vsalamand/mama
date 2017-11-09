json.results @search do |recipe|
  json.title recipe.title
  json.link recipe_path(recipe)
  json.tags recipe.tag_list
  json.id recipe.id
  json.servings recipe.servings
  json.ingredients recipe.ingredients.split("\r\n")
end
