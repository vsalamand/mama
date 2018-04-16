require 'open-uri'

json.menus @menus do |menu|
  json.menu_name menu.name
  json.menu_last_update menu.updated_at
  content = []
  menu.recipes.each do |recipe|
    content << recipe.title
  end
  json.menu_recipes menu.recipes.any? ? content.join(', ') : nil
  json.menu_id menu.id
end
