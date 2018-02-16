json.title @recommendation.title
json.link @recommendation.link
json.tags @recommendation.tag_list
json.id @recommendation.id
json.servings @recommendation.servings
ingredients = []
@recommendation.items.order(:id).select { |item| ingredients << "#{item.ingredient.name.downcase}" }
json.ingredients ingredients.join(', ')
json.valid_user @user
