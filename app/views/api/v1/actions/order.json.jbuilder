require 'open-uri'

json.order_id @order.id
json.order_type @order.order_type
json.order @order.cart_items do |cart_item|
  json.product_name cart_item.name
  json.quantity cart_item.quantity
  json.product_ingredients "#{cart_item.productable.foods.count} ingrédients"
  json.product_type cart_item.productable_type
  json.product_id cart_item.productable_id
  json.product_link cart_item.productable.link
  json.card cl_image_path("#{cart_item.productable_id}",  :format => :png)
end
  # ingredients = []
  #   cart_item.productable.foods.each { |food| ingredients << "#{food.name.downcase}" }
  # json.product_ingredients ingredients.join(', ')
  # case
  #   when cart_item.productable.rating == "excellent" then json.product_rating "💚💖 excellent pour la consommation"
  #   when cart_item.productable.rating == "good" then json.product_rating "💚 bon pour la consommation"
  #   when cart_item.productable.rating == "limit" then json.product_rating "💛 consommation à limiter"
  #   when cart_item.productable.rating == "avoid" then json.product_rating "❤️ consommation à éviter"
  #   else json.product_rating ""
  # end
