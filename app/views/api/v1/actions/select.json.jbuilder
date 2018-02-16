json.title @recipe.title
json.link @recipe.link
json.tags @recipe.tag_list
json.id @recipe.id
json.servings @recipe.servings
json.ingredients @recipe.ingredients.split("\r\n")
json.valid_user @user
