require 'open-uri'

json.cart @cart.cart_items do |cart_item|
  json.name cart_item.name
  json.quantity cart_item.quantity
  json.product_type cart_item.productable_type
  json.product_id cart_item.productable_id
end
