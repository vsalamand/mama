json.title @recommendation.title
json.link @recommendation.link
json.tags @recommendation.tag_list
json.id @recommendation.id
json.servings @recommendation.servings
json.ingredients @recommendation.ingredients.split("\r\n")
