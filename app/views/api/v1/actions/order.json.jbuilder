require 'open-uri'

json.order_id @order.id
json.order_type @order.order_type
json.order @order.cart_items do |cart_item|
  json.product_name cart_item.name
  json.quantity cart_item.quantity
  ingredients = []
    cart_item.productable.foods.each { |food| ingredients << "#{food.name.downcase}" }
  json.product_ingredients ingredients.join(', ')
  json.product_type cart_item.productable_type
  json.product_id cart_item.productable_id
  json.product_link cart_item.productable.link
end
