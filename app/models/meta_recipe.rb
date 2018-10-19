class MetaRecipe < ApplicationRecord
  has_many :meta_recipe_items, dependent: :destroy
  has_many :foods, through: :meta_recipe_items
  has_many :meta_recipe_list_items, dependent: :destroy, inverse_of: :meta_recipe
  has_many :meta_recipe_lists, through: :meta_recipe_list_items
  validates :name, uniqueness: :true
  validates :name, :servings, :ingredients, presence: :true

  accepts_nested_attributes_for :meta_recipe_list_items

  # create meta recipe items
  after_create do
    ingredients = self.ingredients.split("\r\n")
    self.create_meta_recipe_items(ingredients)
  end

  after_update do
    # update meta recipe items
    self.update_meta_recipe_items if self.ingredients_changed?
    # update meta recipe list & list items names
    if self.name_changed?
      self.update_meta_recipe_list_items
      self.update_meta_recipe_lists
    end
    # self.servings
    # self.ingredients
    # self.instructions
    # self.meta_type
  end

  def create_meta_recipe_items(ingredients)
    ingredients.each do |element|
      element = element.strip
      food = Food.search(element.tr("0-9", "").tr("'", " "), fields: [{name: :exact}], misspellings: {edit_distance: 1})
      food = Food.search(element.tr("0-9", "").tr("'", " ")) if food.first.nil?
      food = Food.search(element.tr("0-9", "").tr("'", " "), operator: "or") if food.first.nil?
      MetaRecipeItem.create(food: food.first, meta_recipe: self, name: element, ingredient: element)
    end
  end

  def destroy_meta_recipe_items(ingredients)
    ingredients.each do |ingredient|
      element = MetaRecipeItem.find_by(meta_recipe: self, ingredient: ingredient, name: ingredient)
      element.destroy unless element.nil?
    end
  end

  def get_topping_ingredient
    self.ingredients = self.name
  end

  def update_meta_recipe_items
      previous_ingredients = self.changes[:ingredients].first.split("\r\n")
      saved_ingredients = self.changes[:ingredients].second.split("\r\n")

      removed_ingredients = previous_ingredients - saved_ingredients
      self.destroy_meta_recipe_items(removed_ingredients) if removed_ingredients.any?
      new_ingredients = saved_ingredients - previous_ingredients
      self.create_meta_recipe_items(new_ingredients) if new_ingredients.any?
  end

  def update_meta_recipe_list_items
    self.meta_recipe_list_items.each { |item| item.get_name }
  end

  def update_meta_recipe_lists
    self.meta_recipe_lists.where(list_type: "recipe").each do |list|
      list.name = list.get_title
      list.save
    end
  end

end
