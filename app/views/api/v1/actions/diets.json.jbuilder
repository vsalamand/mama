require 'open-uri'

json.diets @diets.each do |diet|
  json.name diet.name
  json.description  diet.description
  json.id diet.id
end
