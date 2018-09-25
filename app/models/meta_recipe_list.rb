class MetaRecipeList < ApplicationRecord
  belongs_to :recipe, optional: :true
  validates :name, presence: :true, uniqueness: :true
  has_many :meta_recipe_list_items, dependent: :destroy, inverse_of: :meta_recipe_list
  has_many :meta_recipes, through: :meta_recipe_list_items

  accepts_nested_attributes_for :meta_recipe_list_items


  # generate a recipe based on the list of meta recipes
  after_create do
    recipe = Recipe.create(title: self.get_title, servings: 1, ingredients: self.get_ingredients, instructions: self.get_instructions, status: "pending", origin: "generated")
    recipe.generate_items

    # link meta recipe list to the recipe
    self.recipe_id = recipe.id
    self.save
  end

  def get_title
    titles = []
    self.meta_recipe_list_items.each do |meta_recipe_item|
      titles << meta_recipe_item.meta_recipe.name
    end
    return titles.join(', ').capitalize
  end

  def get_instructions
    instructions = []
    self.meta_recipe_list_items.each do |meta_recipe_item|
      instructions << "<strong>#{meta_recipe_item.meta_recipe.name.capitalize}:</strong> #{meta_recipe_item.meta_recipe.instructions}"
    end
    return instructions.join("\r\n")
  end

  def get_ingredients
    foods = []
    ingredients = []
    self.meta_recipe_list_items.each do |meta_recipe_item|
      # ingredients << meta_recipe_item.meta_recipe.ingredients
      meta_recipe_item.meta_recipe.foods.each { |food| foods << food }
    end
    foods.uniq.sort_by { |food| food.category.id }.each { |food| ingredients << food.name }
    return ingredients.join("\r\n")
  end

end
