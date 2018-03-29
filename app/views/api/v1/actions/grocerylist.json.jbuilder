require 'open-uri'

json.grocerylist @grocery_list do |product|
  json.product product.name
end
