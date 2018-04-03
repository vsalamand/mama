require 'open-uri'

json.cart_id @cart.id
json.cart @cart.cart_items do |cart_item|
  json.product_name cart_item.name
  json.quantity cart_item.quantity
  json.product_type cart_item.productable_type
  json.product_id cart_item.productable_id
  json.product_link cart_item.productable.link
end