class MetaRecipeItem < ApplicationRecord
  belongs_to :meta_recipe
  belongs_to :food, optional: true
  belongs_to :unit, optional: true


  def self.add_meta_recipe_items(meta_recipe)
    ingredients = meta_recipe.ingredients.split("\r\n")
    ingredients.each do |element|
      element = element.strip
      food = Food.search(element.tr("0-9", "").tr("'", " "), fields: [{name: :exact}], misspellings: {edit_distance: 1})
      food = Food.search(element.tr("0-9", "").tr("'", " ")) if food.first.nil?
      food = Food.search(element.tr("0-9", "").tr("'", " "), operator: "or") if food.first.nil?
      MetaRecipeItem.create(food: food.first, meta_recipe: meta_recipe, name: element, ingredient: element, quantity: food.serving, unit: food.unit)
    end
  end

  def self.update_meta_recipe_items(meta_recipe)
    ingredients = meta_recipe.ingredients.split("\r\n")
    ingredients.each do |element|
      mr_item = MetaRecipeItem.find_by(meta_recipe: meta_recipe, ingredient: element)
      unless mr_item.nil?
        mr_item.quantity = mr_item.food.serving if mr_item.food.serving.present?
        mr_item.unit = mr_item.food.unit if mr_item.food.unit.present?
        mr_item.save
      end
    end
  end

end

