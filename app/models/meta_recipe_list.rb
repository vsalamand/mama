class MetaRecipeList < ApplicationRecord
  belongs_to :recipe, optional: :true
  validates :name, presence: :true, uniqueness: :true
  has_many :meta_recipe_list_items, dependent: :destroy, inverse_of: :meta_recipe_list
  has_many :meta_recipes, through: :meta_recipe_list_items

  accepts_nested_attributes_for :meta_recipe_list_items, allow_destroy: true

  LIST_TYPE = ["recipe", "pool"]


  # generate a recipe based on the list of meta recipes
  after_create do
    self.create_recipe if self.list_type == "recipe"
    self.tag_recipe
  end

  def create_recipe
    recipe = Recipe.create(title: self.get_title, servings: 1, ingredients: self.get_ingredients, instructions: self.get_instructions, status: "pending", origin: "mama")
    recipe.generate_items
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
    toppings = []
    self.meta_recipe_list_items.each do |meta_recipe_item|
      unless meta_recipe_item.meta_recipe.instructions.empty?
        instructions << "<strong>#{meta_recipe_item.meta_recipe.name.capitalize}:</strong> #{meta_recipe_item.meta_recipe.instructions.gsub("\r\n", " ")}" unless meta_recipe_item.meta_recipe.instructions.empty?
      else
        toppings << meta_recipe_item.meta_recipe.name
      end
    end
    instructions << "<strong>Garniture:</strong> #{toppings.join(", ")}" if toppings.any?
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

  def tag_recipe
    tags = []
    self.meta_recipe_list_items.each { |item| tags << item.get_tags }
    tags = tags.uniq.flatten.join(', ')
    self.recipe.tag_list = tags
    self.recipe.save
  end

end
