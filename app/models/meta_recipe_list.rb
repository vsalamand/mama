class MetaRecipeList < ApplicationRecord
  belongs_to :recipe, optional: :true
  validates :name, presence: :true, uniqueness: :true
  has_many :meta_recipe_list_items, dependent: :destroy, inverse_of: :meta_recipe_list
  has_many :meta_recipes, through: :meta_recipe_list_items
  has_many :foods, through: :meta_recipes

  accepts_nested_attributes_for :meta_recipe_list_items, allow_destroy: true

  LIST_TYPE = ["recipe", "pool"]


  # generate a recipe based on the list of meta recipes
  after_create do
    self.create_recipe if self.list_type == "recipe"
    self.tag_recipe
  end


  def create_recipe
    recipe = Recipe.new(title: self.get_title, servings: 1, ingredients: self.get_ingredients, instructions: self.get_instructions)
    recipe.status = "pending"
    recipe.origin = "mama"
    recipe.save
    recipe.generate_items
    self.recipe_id = recipe.id
    self.save
  end

  def get_title
    titles = self.meta_recipe_list_items.map do |meta_recipe_item|
      meta_recipe_item.meta_recipe.name
    end
    return titles.join(', ').capitalize
  end

  def update_title
    titles = self.meta_recipe_list_items.order(:created_at).map do |meta_recipe_item|
      meta_recipe_item.meta_recipe.name
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
        toppings << meta_recipe_item.meta_recipe.name.capitalize
      end
    end
    instructions << "<strong>Garniture:</strong> #{toppings.join(", ")}" if toppings.any?
    get_extra_instructions(instructions)
    return instructions.join("\r\n")
  end

  def get_extra_instructions(instructions)
    # add extra cooking step for pizza
    if (MetaRecipeList.where(name: "pizzas", list_type: "pool").first.meta_recipes & self.meta_recipes).any?
      instructions << "<strong>Cuisson:</strong> Préchauffer le four à 240°C, déposer la garniture sur la pizza, et laisser cuire 10 minutes environ."
    end
    # add extra cooking step for pies
    if (MetaRecipeList.where(name: "tartes salées", list_type: "pool").first.meta_recipes & self.meta_recipes).any?
      instructions << "<strong>Cuisson:</strong> Préchauffer le four à 200°C, verser le mélange et la garniture, et laisser cuire 30 minutes environ."
    end
  end

  def update_instructions
    recipe = self.recipe
    recipe.instructions = self.get_instructions
    recipe.save
  end

  def get_ingredients
    ingredients = []
    foods = self.foods
    foods.uniq.sort_by { |food| food.category.id }.each { |food| ingredients << food.name }
    return ingredients.join("\r\n")
  end

  def update_ingredients
    recipe = self.recipe
    recipe.ingredients = self.get_ingredients
    recipe.generate_items
    recipe.save
  end

# retrieve pools from meta recipes and turn into tags
  def tag_recipe
    unless self.recipe.nil?
      tags = self.meta_recipe_list_items.order(:id).map { |item| item.get_tags }
      tags = tags.uniq.flatten.join(', ')
      self.recipe.tag_list = tags
      self.recipe.save
    end
  end

  def find_by_meta_recipe_ids(ids)
    return MetaRecipeList.select { |list| ids.compact.delete_if(&:empty?).map { |id| id.to_i }.sort.uniq == list.meta_recipe_ids.sort.uniq  }.first
  end

end
