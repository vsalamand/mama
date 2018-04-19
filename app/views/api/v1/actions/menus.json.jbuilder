require 'open-uri'

json.menus @menus do |menu|
  json.menu_name menu.name
  json.image_url "https://image.ibb.co/bxgehS/rapide.png" if menu.name.include?("rapide")
  json.image_url "https://image.ibb.co/bwuMwn/le_ger.png" if menu.name.include?("léger")
  json.image_url "https://preview.ibb.co/iB5Tbn/snack.png" if menu.name.include?("snack")
  json.image_url "https://image.ibb.co/j0nkNS/tarte.png" if menu.name.include?("tarte salée")
  json.image_url "https://preview.ibb.co/b4hwU7/gourmand.png" if menu.name.include?("gourmand")
  json.menu_last_update menu.updated_at
  content = []
  menu.recipes[-5, 5].each do |recipe|
    content << recipe.title
  end
  json.menu_recipes menu.recipes.any? ? content.reverse.join("\n") : nil
  json.menu_id menu.id
end
