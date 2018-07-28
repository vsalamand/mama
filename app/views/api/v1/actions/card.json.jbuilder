require 'open-uri'

json.id @recipe.id
json.name @recipe.title
json.card cl_image_path("#{@recipe.id}",  :format => :png)
