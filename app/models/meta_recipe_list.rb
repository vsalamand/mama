class MetaRecipeList < ApplicationRecord
  belongs_to :recipe, optional: :true
  validates :name, presence: :true, uniqueness: :true
  has_many :meta_recipe_list_items, dependent: :destroy
  has_many :meta_recipes, through: :meta_recipe_list_items

  # generate a recipe based on the list of meta recipes
  after_create do

   # => define methods for after create

   # retrieve meta recipes information
    titles = []
    ingredients = []
    foods = []
    instructions = []
    elements = 0
    self.meta_recipe_list_items.each do |meta_recipe_item|
      titles << meta_recipe_item.meta_recipe.name
      ingredients << meta_recipe_item.meta_recipe.ingredients
      meta_recipe_item.meta_recipe.foods.each { |food| foods << food}
      instructions << "#{meta_recipe_item.meta_recipe.name.capitalize} :\r\n#{meta_recipe_item.meta_recipe.instructions}"
      elements += 1
    end

    # define recipe title
    recipe_title = titles.join(', ').capitalize # => IMPROVE FOR UNIQUE METARECIPE + ADD "et"

    # define recipe ingredients
    recipe_ingredients = []
    foods.uniq.sort_by { |food| food.category.id }.each { |food| recipe_ingredients << food.name }
    recipe_ingredients = recipe_ingredients.join("\r\n")

    # define recipe instructions
    recipe_instructions = instructions.join("\r\n")


    #. create recipe
    recipe = Recipe.create(title: recipe_title, servings: 1, ingredients: recipe_ingredients, instructions: recipe_instructions, status: "pending", origin: "generated")
    recipe.generate_items

    # link meta recipe list to the recipe
    self.recipe_id = recipe.id
    self.save
  end

end
