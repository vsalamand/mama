class MetaRecipe < ApplicationRecord
  has_many :meta_recipe_items, dependent: :destroy
  has_many :foods, through: :meta_recipe_items
  has_many :meta_recipe_list_items, dependent: :destroy, inverse_of: :meta_recipe
  has_many :meta_recipe_lists, through: :meta_recipe_list_items
  validates :name, uniqueness: :true
  validates :name, :servings, :ingredients, presence: :true

  accepts_nested_attributes_for :meta_recipe_list_items

  META_TYPE = ["veggetable", "starch", "legume", "egg", "meat", "fish", "seafood", "delicatessen", "cheese", "bread", "dressing", "seasoning", "sauce"]

  # generate meta recipe items
  after_create do
    ingredients = self.ingredients.split("\r\n")
    ingredients.each do |element|
        element = element.strip
        food = Food.search(element.tr("0-9", "").tr("'", " "), fields: [{name: :exact}], misspellings: {edit_distance: 1})
        food = Food.search(element.tr("0-9", "").tr("'", " ")) if food.first.nil?
        food = Food.search(element.tr("0-9", "").tr("'", " "), operator: "or") if food.first.nil?
        MetaRecipeItem.create(food: food.first, meta_recipe: self, name: element, ingredient: element)
      end
  end

  def get_topping_ingredient
    self.ingredients = self.name
  end

end
