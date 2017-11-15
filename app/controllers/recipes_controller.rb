require 'open-uri'
require 'hangry'

class RecipesController < ApplicationController
  before_action :set_recipe, only: [ :show, :edit, :update, :set_published_status, :set_dismissed_status ]
  skip_before_action :authenticate_user!, only: [ :show, :new, :create ]

  def pending
    @recipes = Recipe.where(status: "pending")
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params)
    if @recipe.link
      recipe_parser(@recipe.link)
    else
      @recipe.origin = "mama"
    end
    @recipe.status = "pending"
    if @recipe.save
      generate_recipe_items(@recipe)
      redirect_to confirmation_path
    else
      render 'new'
    end
  end

  def edit
  end

  def set_published_status
    @recipe.status = "published"
    @recipe.save
    redirect_to recipe_path(@recipe)
  end

  def set_dismissed_status
    @recipe.status = "dismissed"
    @recipe.save
    redirect_to recipe_path(@recipe)
  end

  private
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(:title, :servings, :ingredients, :instructions, :tag_list, :origin, :status, :link)
  end

  def generate_recipe_items(recipe)
  recipe = Recipe.find(recipe)
  recipe_ingredients = recipe.ingredients.split("\r\n")
  recipe_ingredients.each do |element|
      ingredient = Ingredient.search(element.tr("0-9", "").tr("'", " "), operator: "or")
      element_less_ingredient = element.tr("0-9", "").downcase.split - ingredient[0]["name"].downcase.split
      unit = Unit.search(element_less_ingredient.join(' '), operator: "or")
      quantity = element[/[+-]?([0-9]*[\D])?[0-9]+/]
      Item.create(ingredient: ingredient[0], unit: unit[0], quantity: quantity, recipe: recipe, recipe_ingredient: element)
    end
  end

  def recipe_parser(url)
    recipe_url = "#{url}"
    url_host = URI.parse(url).host
    if url_host == "www.cuisineaz.com"
      cuisineaz(recipe_url)
    elsif url_host == "www.marmiton.org" || url_host == "m.marmiton.org"
      marmiton(recipe_url)
    elsif url_host == "www.750g.com"
      septcentcinquanteg(recipe_url)
    else
      schema_org_recipe(recipe_url)
    end
    @recipe.link = url
    @recipe.origin = url_host
  end

  def cuisineaz(url)
    page =  Nokogiri::HTML(open(url).read)
    @recipe.title = page.css('h1').text
    instructions = []
    page.css("#preparation p").each { |step_node| instructions << step_node.text }
    @recipe.instructions = instructions.join("\r\n")
    ingredients = []
    page.css("section.recipe_ingredients li").each { |ing_node| ingredients << ing_node.text }
    @recipe.ingredients = ingredients.join("\r\n")
    @recipe.servings = page.css("#ContentPlaceHolder_LblRecetteNombre").text.to_i
  end

  def marmiton(url)
    page =  Nokogiri::HTML(open(url).read)
    @recipe.title = page.css('h1').text
    @recipe.servings = page.css('recipe-infos__quantity > span.title-2 recipe-infos__quantity__value').text.to_i
    ingredients = []
    ingredients_text = page.css('ul.recipe-ingredients__list li.recipe-ingredients__list__item').each do |ingredient_tag|
      ingredients << ingredient_tag.text.gsub(/\n/, "").gsub(/\t/, "").gsub(/\r/, "")
    end
    @recipe.ingredients = ingredients.join("\r\n")
    steps = []
    steps_text = page.css('ol.recipe-preparation__list').each do |step_tag|
      steps << step_tag.text
    end
    @recipe.instructions = steps.join("\r\n")
  end

  def septcentcinquanteg(url)
    page =  Nokogiri::HTML(open(url).read)
    @recipe.title = page.css('h1.c-article__title').text
    instructions = []
    page.css('div.c-recipe-steps div.c-recipe-steps__item-content p').each do |element|
      instructions << element.text
    end
    binding.pry
    @recipe.instructions = instructions.join("\r\n")
    ingredients = []
    css_ingredient = "div.c-recipe-ingredients ul.c-recipe-ingredients__list li.ingredient"
    page.css(css_ingredient).each { |ing_node|
      ingredients << ing_node.text
    }
    @recipe.servings = page.css('div.u-margin-vert.u-border-top.u-border-bottom > h2').text.gsub(/[^0-9]/, '').to_i
    @recipe.ingredients = ingredients.join("\r\n")
  end

  def schema_org_recipe(url)
    recipe_html_string = open(recipe_url).read
    recipe = Hangry.parse(recipe_html_string)
    @recipe.title = recipe.name
    @recipe.servings = recipe.yield
    @recipe.ingredients = recipe.ingredients.join("\r\n")
    @recipe.instructions = recipe.instructions
  end
end
