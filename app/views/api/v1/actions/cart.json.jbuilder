require 'open-uri'

json.cart_id @cart.id
json.image_url "https://image.ibb.co/g7qpz7/cart.png"
json.cart_count @cart.cart_items.count
json.cart @cart.cart_items do |cart_item|
  json.product_name cart_item.name.upcase
  ingredients = []
    cart_item.productable.foods.each { |food| ingredients << "#{food.name.downcase}" }
  json.product_ingredients ingredients.join(', ')
  json.quantity cart_item.quantity
  json.product_type cart_item.productable_type
  json.product_id cart_item.productable_id
  json.product_link cart_item.productable.link
end
