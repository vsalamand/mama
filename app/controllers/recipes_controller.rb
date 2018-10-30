require 'open-uri'
require 'hangry'

# REFACTO TO DO...

class RecipesController < ApplicationController
  before_action :set_recipe, only: [ :show, :card, :edit, :update, :set_published_status, :set_dismissed_status ]
  skip_before_action :authenticate_user!, only: [ :show, :card, :new, :create ]

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "recipe_card",
               orientation: 'Landscape',
               page_size: 'A5',
               zoom:  0.32,
               background: true,
               margin:  {
                    top:               5,                     # default 10 (mm)
                    bottom:            0,
                    left:              5,
                    right:             5
               }
      end
    end
  end

  def card
  end

  def pending
    @recipes = Recipe.where(status: "pending")
  end

  def new
    @recipe = Recipe.new
  end

  def import
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.status = "pending"
    if @recipe.link
      recipe_parser(@recipe.link)
      if @recipe.save
        @recipe.generate_items
        redirect_to confirmation_path
      else
        redirect_to import_recipes_path
      end
    else
      @recipe.origin = "mama"
      if @recipe.save
        @recipe.generate_items
        redirect_to confirmation_path
      else
        redirect_to new_recipe_path
      end
    end
  end

  def edit
  end

  def set_published_status
    @recipe.status = "published"
    # generate_ingredients_tags(@recipe)
    @recipe.save
    @recipe.add_to_pool
    @recipe.rate
    @recipe.upload_to_cloudinary
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
    params.require(:recipe).permit(:title, :servings, :ingredients, :instructions, :tag_list, :origin, :status, :link, :rating)
  end

  # def generate_ingredients_tags(recipe)
  #   recipe = Recipe.find(recipe)
  #   ingredients = []
  #   recipe.items.each { |item| ingredients << item.food }
  #   tags = []
  #   ingredients.each { |ingredient| ingredient.tags.each { |tag| tags << tag.name} }
  #   recipe.tag_list.add(tags.uniq.join(', '), parse: true)
  #   recipe.save
  # end

# RECIPE PARSERS ==> REFACTO and MOVE
  def recipe_parser(url)
    recipe_url = "#{url}"
    url_host = URI.parse(url).host
    if url_host == "www.cuisineaz.com"
      cuisineaz(recipe_url)
    elsif url_host == "www.wecook.fr"
      wecook(recipe_url)
    elsif url_host == "www.marmiton.org" || url_host == "m.marmiton.org"
      marmiton(recipe_url)
    elsif url_host == "www.750g.com"
      septcentcinquanteg(recipe_url)
    elsif url_host == "www.unjourunerecette.fr"
      unjourunerecette(recipe_url)
    elsif url_host == "www.mangerbouger.fr"
      mangerbouger(recipe_url)
    elsif url_host =="www.club-sandwich.net"
      club_sandwich(recipe_url)
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
    page.css("#preparation p").each do |step_node|
      page.css("#preparation p span").remove
      instructions << step_node.text
    end
    @recipe.instructions = instructions.join("\r\n")
    ingredients = []
    page.css("section.recipe_ingredients li").each { |ing_node| ingredients << ing_node.text }
    @recipe.ingredients = ingredients.join("\r\n")
    @recipe.servings = page.css("#ContentPlaceHolder_LblRecetteNombre").text.to_i
  end

  def marmiton(url)
    page =  Nokogiri::HTML(open(url).read)
    @recipe.title = page.css('h1').text
    @recipe.servings = page.css('div.recipe-infos__quantity').text.gsub(/[^0-9]/, '').to_i
    ingredients = []
    page.css('li.recipe-ingredients__list__item').each do |ingredient_tag|
      ingredients << ingredient_tag.text.gsub(/\n/, "").gsub(/\t/, "").gsub(/\r/, "")
    end
    @recipe.ingredients = ingredients.join("\r\n")
    steps = []
    page.css('ol.recipe-preparation__list li').each do |step_tag|
      page.css('ol.recipe-preparation__list h3').remove
      steps << step_tag.text.gsub(/\n/, "").gsub(/\t/, "").gsub(/\r/, "")
    end
    @recipe.instructions = steps.join("\r\n")
  end

  def septcentcinquanteg(url)
    page = Nokogiri::HTML(open(url).read)
    @recipe.title = page.css('h1.c-article__title').text
    instructions = []
    page.css('div.c-recipe-steps__item-content').each do |element|
      instructions << element.text
    end
    @recipe.instructions = instructions.join("\r\n")
    ingredients = []
    css_ingredient = "div.c-recipe-ingredients ul.c-recipe-ingredients__list li.ingredient"
    page.css(css_ingredient).each { |ing_node|
      ingredients << ing_node.text.strip
    }
    @recipe.servings = page.css('div.u-margin-vert.u-border-top.u-border-bottom > h2').text.gsub(/[^0-9]/, '').to_i
    @recipe.ingredients = ingredients.join("\r\n")
  end

  def wecook(url)
    page =  Nokogiri::HTML(open(url).read)
    @recipe.title = page.css('[itemprop = "name"]').first.content
    @recipe.servings = page.css('[itemprop = "recipeYield"]').first.content
    ingredients = []
    count = page.css('div.ingredient').count / 2
    i = 0
    until i == count
      ingredients << page.css('div.ingredient')[i].text
      i += 1
    end
    @recipe.ingredients = ingredients.join("\r\n")
    instructions = []
    page.css('[itemprop = "recipeInstructions"] span.step-description').each do |element|
      instructions << element.text
    end
    @recipe.instructions = instructions.join("\r\n")
  end

  def unjourunerecette(url)
    page =  Nokogiri::HTML(open(url).read)
    @recipe.title = page.css('h1').text
    instructions = []
    page.css("#preparation li span").each do |step_node|
      instructions << step_node.text
    end
    @recipe.instructions = instructions.join("\r\n")
    @recipe.servings = page.css('.courses .yield').text.gsub(/[^0-9]/, '').to_i
    ingredients = []
    page.css('.ingredient').each do |ing|
      ingredients << ing.text
    end
    @recipe.ingredients = ingredients.join("\r\n")
  end

  def mangerbouger(url)
    page =  Nokogiri::HTML(open(url).read)
    @recipe.title = page.css('.title-huge').text.strip
    instructions = []
    page.css(".article-content p").each do |step_node|
      instructions << step_node.text
    end
    @recipe.instructions = instructions.join("\r\n")
    @recipe.servings = page.css('.detail .label').first.text.gsub(/[^0-9]/, '').to_i
    ingredients = []
    page.css('.detail > ul > li').each do |ing|
      ingredients << ing.text
    end
    @recipe.ingredients = ingredients.join("\r\n")
  end

  def club_sandwich(url)
    page =  Nokogiri::HTML(open(url).read)
    @recipe.title = page.css('.fn').text
    @recipe.servings = 1
    instructions = []
    page.css(".instructions li").each do |step_node|
      instructions << step_node.text.gsub(/\n/, "").gsub(/\t/, "").gsub(/\r/, "")
    end
    @recipe.instructions = instructions.join("\r\n")
    ingredients = []
    page.css(".ingredients li").each do |ing|
      ingredients << ing.text.gsub(/\n/, "").gsub(/\t/, "").gsub(/\r/, "")
    end
    @recipe.ingredients = ingredients.join("\r\n")
  end

  def schema_org_recipe(url)
    recipe_html_string = open(url).read
    recipe = Hangry.parse(recipe_html_string)
    unless recipe.ingredients.nil?
      @recipe.title = recipe.name
      @recipe.servings = recipe.yield
      @recipe.ingredients = recipe.ingredients.join("\r\n")
      @recipe.instructions = recipe.instructions
    end
  end
end
