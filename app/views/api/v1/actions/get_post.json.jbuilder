require 'open-uri'

# json.context "get_recommendations"
json.id @recommendation.id
json.name @recommendation.name
json.description @recommendation.description
json.image_url @recommendation.image_url
json.link @recommendation.link

json.items @recommendation.recommendation_items.each do |item|
  json.name item.name
  json.id item.id
  json.recipe_list_id item.recipe_list_id
  json.recipe_list_name item.recipe_list.name
end
