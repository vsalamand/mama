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
    recipe = Recipe.new(title: self.get_title, servings: 1, ingredients: self.list_ingredients, instructions: self.get_instructions, link: self.link, origin: self.author)
    recipe.status = "pending"
    recipe.origin = "mama" if recipe.origin.blank?
    recipe.save
    Thread.new do
      Item.add_recipe_items(recipe)
    end
    self.recipe_id = recipe.id
    self.save
  end

  def update_recipe
    recipe = self.recipe
    recipe.ingredients = self.list_ingredients
    recipe.instructions = self.get_instructions
    recipe.save
    Thread.new do
      Item.update_recipe_items(recipe)
    end
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
    seasonings = []

    self.meta_recipe_list_items.order(:updated_at).each do |meta_recipe_item|

      if meta_recipe_item.meta_recipe.instructions?
        instructions << "<strong>#{meta_recipe_item.meta_recipe.name.capitalize}:</strong> #{meta_recipe_item.meta_recipe.instructions.gsub("\r\n", " ")}" unless meta_recipe_item.meta_recipe.instructions.empty?

      elsif (meta_recipe_item.meta_recipe.group_list & ["sauces", "vinaigrettes", "assaisonnements"]).any?
        seasonings << meta_recipe_item.meta_recipe.name.capitalize

      else
        toppings << meta_recipe_item.meta_recipe.name.capitalize
      end
    end
    instructions << "<strong>Garniture:</strong> #{toppings.join(", ")}" if toppings.any?
    instructions << "<strong>Assaisonnement:</strong> #{seasonings.join(", ")}" if seasonings.any?

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
    unless self.recipe.nil?
      recipe = self.recipe
      recipe.instructions = self.get_instructions
      recipe.save
      recipe.upload_to_cloudinary
    end
  end

  def get_ingredients_data
    # get meta recipe list items
    mrl_items = self.meta_recipe_list_items.order(:id)
    # get related meta recipe items
    mr_items = mrl_items.map { |mrl_item| mrl_item.meta_recipe_items.order(:id) }.flatten
    # sort by food categories
    sorted_items = mr_items.sort_by { |item| item.food }
    # get ingredients lines from items
    data = Hash.new
    sorted_items.each do |item|
      if data.has_key?("#{item.name}")
        data["#{item.name}"]["quantity"].present? ? data[item.name]["quantity"] = item.quantity + data["#{item.name}"]["quantity"] : data[item.name]["quantity"] = item.quantity
      else
        data[item.name] = Hash.new
        data[item.name]["quantity"] = item.quantity
        data[item.name]["unit"] = item.unit
      end
    end
    return data
  end

  def list_ingredients
    # retrieve ingredients hash
    data = self.get_ingredients_data
    # get ingredients text from data
    ingredients = []
    data.each do |key, hash|
      ingredients << "#{key} (#{hash["quantity"] if hash["quantity"].present?} #{hash["unit"].name if hash["unit"].present?})"
    end
    return ingredients.join("\r\n")
  end

  def update_ingredients_items
    # retrieve ingredients hash
    data = self.get_ingredients_data
    # get recipe
    recipe = self.recipe
    # get ingredients text from data and match with recipe items
    recipe.items.each do |item|
      if data.has_key?(item.name.strip)
        item.quantity = data[item.name.strip]["quantity"]
        item.unit = data[item.name.strip]["unit"] if data[item.name.strip]["unit"].present?
        item.name = "#{item.name.strip} (#{item.quantity} #{item.unit.name if item.unit.present?})"
        item.save
      end
    end
    # update recipe ingredients and items
    recipe.ingredients = self.list_ingredients
    # recipe.generate_items
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
