# json.recipes @suggestions do |array|
#   array.each do |recipe|
#     json.title recipe.title
#     json.link recipe_path(recipe)
#     json.tags recipe.tag_list
#     json.id recipe.id
#     json.servings recipe.servings
#     json.ingredients recipe.ingredients.split("\r\n")
#   end
# end

json.recommended do
  json.title @recommended.first.title
  json.link recipe_path(@recommended.first)
  json.tags @recommended.first.tag_list
  json.id @recommended.first.id
  json.servings @recommended.first.servings
  json.ingredients @recommended.first.ingredients.split("\r\n")
  json.imageurl "https://s1.postimg.org/9qrloncob3/recommande.png"
end
json.express do
  json.title @express.first.title
  json.link recipe_path(@express.first)
  json.tags @express.first.tag_list
  json.id @express.first.id
  json.servings @express.first.servings
  json.ingredients @express.first.ingredients.split("\r\n")
  json.imageurl "https://s1.postimg.org/255fpwp1fz/express.png"
end
json.salad do
  json.title @salad.first.title
  json.link recipe_path(@salad.first)
  json.tags @salad.first.tag_list
  json.id @salad.first.id
  json.servings @salad.first.servings
  json.ingredients @salad.first.ingredients.split("\r\n")
  json.imageurl "https://s1.postimg.org/2mwrcbibtb/salade.png"
end
json.dish do
  json.title @dish.first.title
  json.link recipe_path(@dish.first)
  json.tags @dish.first.tag_list
  json.id @dish.first.id
  json.servings @dish.first.servings
  json.ingredients @dish.first.ingredients.split("\r\n")
  json.imageurl "https://s1.postimg.org/7hp6crpdq7/platdujour.png"
end

