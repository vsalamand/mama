require 'open-uri'

json.image_url "https://image.ibb.co/hgY9z7/recommandations.png"
json.menus @recommendations do |reco|
  json.basket_name reco.name
  json.basket_emoji "🥕" if reco.name.include?("classique")
  json.basket_emoji "🍕" if reco.name.include?("express")
  json.basket_emoji "🍽️" if reco.name.include?("gourmand")
  # json.image_url "https://image.ibb.co/mKinmn/express.png" if reco.name.include?("rapide")
  # json.image_url "https://image.ibb.co/hcQsmn/light.png" if reco.name.include?("léger")
  # json.image_url "https://image.ibb.co/gMonmn/snack.png" if reco.name.include?("snack")
  # json.image_url "https://image.ibb.co/b3uhK7/tarte.png" if reco.name.include?("tarte salée")
  # json.image_url "https://image.ibb.co/ng1jXS/gourmand.png" if reco.name.include?("gourmand")
  json.basket_last_update reco.updated_at
  content = []
  reco.recipes[-10, 10].each do |recipe|
    content << recipe.title
  end
  json.basket_recipes reco.recipes.any? ? content.reverse.join("\n") : nil
  json.basket_id reco.id
end
