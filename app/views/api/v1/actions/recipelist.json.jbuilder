require 'open-uri'

json.recipelist_name @recipe_list.name
json.image_url "https://image.ibb.co/mKinmn/express.png" if @recipe_list.name.include?("rapide")
json.image_url "https://image.ibb.co/h2gUz7/light.png" if @recipe_list.name.include?("léger")
json.image_url "https://image.ibb.co/gMonmn/snack.png" if @recipe_list.name.include?("snack")
json.image_url "https://image.ibb.co/b3uhK7/tarte.png" if @recipe_list.name.include?("tarte salée")
json.image_url "https://image.ibb.co/ng1jXS/gourmand.png" if @recipe_list.name.include?("gourmand")
json.recipelist_description @recipe_list.description
json.recipelist_count @recipe_list.recipes.count
json.recipelist_id @recipe_list.id
json.recipelist_type @recipe_list.recipe_list_type
json.recipes @recipe_list.recipe_list_items[-5, 5].reverse.each do |item|
  json.name item.recipe.title
  ingredients = []
    item.recipe.foods.each { |food| ingredients << "#{food.name.downcase}" }
  json.ingredients ingredients.join("\n")
  json.id item.recipe.id
  json.link item.recipe.link
end
