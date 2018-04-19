require 'open-uri'

json.image_url "https://image.ibb.co/iUoL6n/history.png"
json.order_history @order_history do |order|
  json.order_id order.id
  json.date order.created_at.strftime("%d/%m/%Y")
  json.items_count order.cart_items.count
  order_items = []
    order.recipes.each { |recipe| order_items << recipe.title}
  json.items order_items.join(', ')
end
