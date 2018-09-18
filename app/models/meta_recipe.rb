class MetaRecipe < ApplicationRecord
  has_many :meta_recipe_items, dependent: :destroy
  has_many :foods, through: :meta_recipe_items
  validates :name, uniqueness: :true
  validates :name, :servings, :ingredients, :instructions, presence: :true

  # generate meta recipe items
  after_create do
    ingredients = self.ingredients.split("\r\n")
    ingredients.each do |element|
        element = element.strip
        food = Food.search(element.tr("0-9", "").tr("'", " "), operator: "or")
        MetaRecipeItem.create(food: food.first, meta_recipe: self, name: element, ingredient: element)
      end
  end

end
