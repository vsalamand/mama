require 'open-uri'

json.count @recommendations.size
json.context "get_recommendations"
json.recommendations @recommendations.each do |recommendation|
  json.item_id recommendation.id
  json.recipe_id recommendation.id
  json.link card_recipe_url(recommendation.id)
  json.name recommendation.title
  json.tags recommendation.tag_list
  json.category recommendation.category_list
  json.checklist Checklist.get_checklist(recommendation.foods)
  json.emoji recommendation.get_emoji
  json.rank @recommendations.index(recommendation)
end
