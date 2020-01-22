require 'open-uri'
require 'hangry'

# REFACTO TO DO...

class RecipesController < ApplicationController
  before_action :set_recipe, only: [ :show, :card, :edit, :update, :set_published_status, :set_dismissed_status, :god_show ]
  skip_before_action :authenticate_user!, only: [ :show, :card, :cart ]
  before_action :authenticate_admin!, only: [:new, :import, :create, :import, :search, :god_show ]

  def show
    @list_item = ListItem.new

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "recipe_card",
               # orientation: 'Landscape',
               # dpi: 300,
               page_size: 'A4',
               # zoom:  0.9,
               background: true,
               show_as_html: params.key?('debug'),
               margin:  {
                    top:               5,                     # default 10 (mm)
                    bottom:            0,
                    left:              5,
                    right:             5
               }
      end
    end
  end

  def god_show
  end

  def card
    # Analytics
    profile = User.find_or_create_by(sender_id: params[:user])
    product = Recipe.find(params[:id])
    position = params[:position]
    context = params[:context]
    if params[:user].present?
      recipe_view = Hash.new
      recipe_view["context"] = context
      recipe_view["position"] = position
      recipe_view["recipe_id"] = product.id
      recipe_view["sender_id"] = params[:user].to_i
      ahoy.track "recipe_view", recipe_view
    end
  end

  def new
    @recipe = Recipe.new
  end

  def index
    @recipes = Recipe.where.not(origin: "mama").where(status: "published").reverse[0..30]
  end

  def import
    @recipe = Recipe.new
  end

  def search
    # @recipes = Recipe.where(status: "published")
    query = params[:query].present? ? params[:query] : nil

    @results = if query
      Recipe.search(query, fields: [:title, :ingredients, :tags, :categories])[0..99]
    end
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.status = "pending"
    if @recipe.title.nil?
      recipe_parser(@recipe.link)
      @recipe.title = @recipe.title.downcase.capitalize
      if @recipe.save
        Item.add_recipe_items(@recipe)
        redirect_to pending_path
      else
        redirect_to import_recipes_path
      end
    else
      @recipe.origin = "mama" if @recipe.origin.blank?
      @recipe.title = @recipe.title.downcase.capitalize
      if @recipe.save
        Item.add_recipe_items(@recipe)
        redirect_to pending_path
      else
        redirect_to new_recipe_path
      end
    end
  end

  def edit
  end

  def update
    @recipe.update(recipe_params)
    redirect_to recipe_path(@recipe)
  end


  def set_published_status
    @recipe.status = "published"
    # generate_ingredients_tags(@recipe)
    @recipe.save
    @recipe.items.each{ |item| item.validate }
    @recipe.rate
    @recipe.add_to_pool
    # @recipe.upload_to_cloudinary
    redirect_to recipe_path(@recipe)
  end

  def set_dismissed_status
    @recipe.status = "dismissed"
    @recipe.save
    @recipe.items.each{ |item| item.unvalidate }
    redirect_to recipe_path(@recipe)
  end

  def cart
    @recipe = Recipe.find(params[:id])
    @store = Store.find(params[:store_id])
  end

  def add_to_list
    @recipe = Recipe.find(params[:id])
    params[:list_id] ? @list = List.find(params[:list_id]) : @list = List.create(name: @recipe.title, user: current_user) if @list.nil?

    @recipe.items.each do |item|
      ListItem.add_to_list(item.name, @list)
    end

    respond_to do |format|
      format.js { flash.now[:notice] = "La liste a été ajoutée !" }
    end
  end

  def fetch_suggested_recipes
    @recipes = RecipeList.where(recipe_list_type: "curated").last.recipes[0..6]
    render 'fetch_suggested_recipes.js.erb'
  end

  def fetch_recipe_card
    @recipe = Recipe.find(params[:id])
    render 'fetch_recipe_card.js.erb'
  end

  def fetch_menu
    @menu = current_user.get_menu
    # @recipes = menu.recipes
    render 'fetch_menu.js.erb'
  end

  def add_to_menu
    recipe = Recipe.find(params[:id])
    @menu = current_user.get_menu
    recipe.add_to_recipe_list(@menu)

    render 'fetch_menu.js.erb'
  end


  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(:title, :servings, :ingredients, :instructions, :tag_list, :origin, :status, :link, :rating, recipe_list_ids: [], recipe_list_items_attributes:[:name, :recipe_list_id, :recipe_id])
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
