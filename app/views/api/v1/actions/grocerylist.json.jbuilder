require 'open-uri'

json.grocerylist @grocery_list do |product|
  json.name product.name
end
