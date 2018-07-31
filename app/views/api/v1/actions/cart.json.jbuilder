require 'open-uri'

json.cart_id @cart.id
json.cart_count @cart.cart_items.count
json.cart @cart.cart_items.reverse do |cart_item|
  json.product_name cart_item.name.upcase
  json.product_ingredients "#{cart_item.productable.foods.count} ingrédients"
  case
    when cart_item.productable.rating == "excellent" then json.product_rating "💚💖 excellent pour la consommation"
    when cart_item.productable.rating == "good" then json.product_rating "💚 bon pour la consommation"
    when cart_item.productable.rating == "limit" then json.product_rating "💛 consommation à limiter"
    when cart_item.productable.rating == "avoid" then json.product_rating "❤️ consommation à éviter"
    else json.product_rating ""
  end
  json.quantity cart_item.quantity
  json.product_type cart_item.productable_type
  json.product_id cart_item.productable_id
  json.product_link card_recipe_url(cart_item.productable_id)
end
