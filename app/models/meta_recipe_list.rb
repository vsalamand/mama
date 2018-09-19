class MetaRecipeList < ApplicationRecord
  belongs_to :recipe, optional: :true
  validates :name, presence: :true, uniqueness: :true
  has_many :meta_recipe_list_items, dependent: :destroy
  has_many :meta_recipes, through: :meta_recipe_list_items

  # generate a recipe based on the list of meta recipes
  after_create do
    # ingredients = self.ingredients.split("\r\n")
    # ingredients.each do |element|
    #     element = element.strip
    #     food = Food.search(element.tr("0-9", "").tr("'", " "), operator: "or")
    #     MetaRecipeItem.create(food: food.first, meta_recipe: self, name: element, ingredient: element)
    #   end
  end

end
