class MetaRecipe < ApplicationRecord
  has_many :meta_recipe_items, dependent: :destroy
  has_many :foods, through: :meta_recipe_items
  has_many :meta_recipe_list_items, dependent: :destroy, inverse_of: :meta_recipe
  has_many :meta_recipe_lists, through: :meta_recipe_list_items
  has_many :recipes, through: :meta_recipe_lists
  has_many :items, through: :recipes
  validates :name, uniqueness: :true
  validates :name, :servings, :ingredients, presence: :true

  accepts_nested_attributes_for :meta_recipe_list_items

  acts_as_ordered_taggable
  acts_as_taggable_on :groups

  # create meta recipe items
  after_create do
    MetaRecipeItem.add_meta_recipe_items(self)
    self.add_groups
  end

  before_save do
    # if update is not a create
    if !self.changes[:created_at].nil? && self.changes[:created_at] =! self.changes[:updated_at]
      # update meta recipe items
      MetaRecipeItem.update_meta_recipe_items(self) if self.ingredients_changed?
      # update meta recipe list & list items names
      if self.name_changed?
        self.update_meta_recipe_list_items
        self.update_meta_recipe_lists
      end
      # update recipe instructions
      self.update_recipe_instructions if self.instructions_changed?
    end
  end

  def add_groups
    pools = []
    self.meta_recipe_lists.where(list_type: "pool").each { |pool| pools << pool.name }
    self.group_list = pools.join(", ")
    self.save
  end

  def get_topping_ingredient
    self.ingredients = self.name
  end

  # def update_ingredients
  #   previous_ingredients = self.changes[:ingredients].first.split("\r\n")
  #   saved_ingredients = self.changes[:ingredients].second.split("\r\n")
  #   # destroy recipe items & mr_items
  #   removed_ingredients = previous_ingredients - saved_ingredients
  #   self.destroy_items(removed_ingredients) if removed_ingredients.any?
  #   # create new mr_items
  #   new_ingredients = saved_ingredients - previous_ingredients
  #   self.create_meta_recipe_items(new_ingredients) if new_ingredients.any?
  #   # update recipe items
  #   self.update_recipe_ingredients
  # end

  # def create_meta_recipe_items(ingredients)
  #   ingredients.each do |element|
  #     element = element.strip
  #     food = Food.search(element.tr("0-9", "").tr("'", " "), fields: [{name: :exact}], misspellings: {edit_distance: 1})
  #     food = Food.search(element.tr("0-9", "").tr("'", " ")) if food.first.nil?
  #     food = Food.search(element.tr("0-9", "").tr("'", " "), operator: "or") if food.first.nil?
  #     MetaRecipeItem.create(food: food.first, meta_recipe: self, name: element, ingredient: element)
  #   end
  # end

  # def destroy_items(ingredients)
  #   ingredients.each do |ingredient|
  #     mr_item = MetaRecipeItem.find_by(meta_recipe: self, ingredient: ingredient, name: ingredient)
  #     # destroy recipe items
  #     self.items.where(food: mr_item.food).each { |item| item.destroy unless item.nil? }
  #     # deetroy metarecipe items
  #     mr_item.destroy unless mr_item.nil?
  #   end
  # end

  def update_recipe_instructions
    self.meta_recipe_lists.where(list_type: "recipe").each { |mrl| mrl.update_instructions }
  end

  def update_recipe_ingredients
    self.meta_recipe_lists.where(list_type: "recipe").each { |mrl| mrl.update_ingredients }
  end

  def update_meta_recipe_list_items
    self.meta_recipe_list_items.each { |item| item.get_name }
  end

  def update_meta_recipe_lists
    self.meta_recipe_lists.where(list_type: "recipe").each do |list|
      list.name = list.update_title
      list.save
      list.recipe.title = list.name
      list.recipe.save
    end
  end

end
