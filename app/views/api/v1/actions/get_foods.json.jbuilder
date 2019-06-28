require 'open-uri'


json.foods @foods.map { |food| food.name }
