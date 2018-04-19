require 'open-uri'

json.image_url "https://image.ibb.co/gLxrCS/grocerylist.png"
json.grocerylist @grocery_list do |product|
  json.product product.name
end
