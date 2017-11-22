require 'open-uri'

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

if @recommended
  json.recommended do
    json.title @recommended.first.title
    json.link @recommended.first.link
    json.domain URI.parse(@recommended.first.link).host
    json.tags @recommended.first.tag_list
    json.id @recommended.first.id
    json.servings @recommended.first.servings
    ingredients = []
    @recommended.first.items.select { |item| ingredients << "#{item.ingredient.name.downcase}" }
    json.ingredients ingredients.join(', ')
    json.imageurl "https://s1.postimg.org/9qrloncob3/recommande.png"
    json.emoji "❤️"
  end
end

# if @express =! []
#   json.express do
#     json.title @express.first.title
#     json.link @express.first.link
#     json.domain URI.parse(@express.first.link).host
#     json.tags @express.first.tag_list
#     json.id @express.first.id
#     json.servings @express.first.servings
#     ingredients = []
#     @express.first.items.select { |item| ingredients << "#{item.ingredient.name.downcase}" }
#     json.ingredients ingredients.join(', ')
#     json.imageurl "https://s1.postimg.org/255fpwp1fz/express.png"
#     json.emoji "💛"
#   end
# end

# if @light =! []
#   json.light do
#     json.title @light.first.title
#     json.link @light.first.link
#     json.domain URI.parse(@light.first.link).host
#     json.tags @light.first.tag_list
#     json.id @light.first.id
#     json.servings @light.first.servings
#     ingredients = []
#     @light.first.items.select { |item| ingredients << "#{item.ingredient.name.downcase}" }
#     json.ingredients ingredients.join(', ')
#     json.imageurl "https://s1.postimg.org/2mwrcbibtb/salade.png"
#     json.emoji "💚"
#   end
# end

# if @snack =! []
#   json.snack do
#     json.title @snack.first.title
#     json.link @snack.first.link
#     json.domain URI.parse(@snack.first.link).host
#     json.tags @snack.first.tag_list
#     json.id @snack.first.id
#     json.servings @snack.first.servings
#     ingredients = []
#     @snack.first.items.select { |item| ingredients << "#{item.ingredient.name.downcase}" }
#     json.ingredients ingredients.join(', ')
#     json.imageurl "https://s1.postimg.org/7hp6crpdq7/platdujour.png"
#     json.emoji "💙"
#   end
# end

# if @dish =! []
#   json.dish do
#     json.title @dish.first.title
#     json.link @dish.first.link
#     json.domain URI.parse(@dish.first.link).host
#     json.tags @dish.first.tag_list
#     json.id @dish.first.id
#     json.servings @dish.first.servings
#     ingredients = []
#     @dish.first.items.select { |item| ingredients << "#{item.ingredient.name.downcase}" }
#     json.ingredients ingredients.join(', ')
#     json.imageurl "https://s1.postimg.org/7hp6crpdq7/platdujour.png"
#     json.emoji "💜"
#   end
# end

