require 'date'

class Api::V1::ActionsController < Api::V1::BaseController

  #http://localhost:3000/api/v1/get_recommendations??type=salad&user=12345678
  def get_recommendations
    # categories = Recipe.category_counts
    categories = Hash.new

    type = params[:type]
    if type.present?
      categories["#{type}"] = 10
    else
      categories["veggie"] = 1
      categories["potato"] = 1
      categories["salad"] = 1
      categories["meat"] = 1
      categories["fish"] = 1
      categories["pasta"] = 1
      categories["pizza"] = 1
      categories["snack"] = 1
    end

    content = []
    categories.each do |category, quantity|
      content << Recipe.where(status: "published").tagged_with(category).shuffle.take(quantity)
    end
    @recommendations = content.flatten.uniq

    respond_to do |format|
      format.json { render :get_recommendations }
    end


    # Analytics
    recommendations = Hash.new
    recommendations["recipes"] = @recommendations.map.with_index { |recipe, index| ["recipe_id_#{index}", recipe.id] }.to_h
    recommendations["type"] = type
    recommendations["sender_id"] = params[:user].to_i
    recommendations["source"] = { version: "shuffle"}
    ahoy.track "get_recommendations", recommendations
  end



  #http://localhost:3000/api/v1/search?query=poireau+butternut+épinards+carottes&user=12345678
  def search
    query = params[:query].present? ? params[:query] : nil

    @search = if query
      Recipe.search(query, fields: [:title, :ingredients, :tags, :categories], where: {status: "published"}, operator: "or")[0..9]
    end

    respond_to do |format|
      format.json { render :search }
    end

    # Analytics
    results = Hash.new
    results["recipes"] = @search.map.with_index { |recipe, index| ["recipe_id_#{index}", recipe.id] }.to_h
    results["query"] = query
    results["sender_id"] = params[:user].to_i
    ahoy.track "search", results
  end



  #http://localhost:3000/api/v1/add_to_cart?product_id=123456&position=0&context=get_reco&user=1191499810899113
  def add_to_cart
    profile = User.find_or_create_by(sender_id: params[:user])
    @cart = Cart.find_or_create_by(user_id: profile.id)
    product = Recipe.find(params[:product_id])
    position = params[:position]
    context = params[:context]
    CartItemsController.create(name: product.title, productable_id: product.id, productable_type: product.class.name, quantity: 1, cart_id: @cart.id)
    #RecipeList.add_to_user_history(profile, product)
    respond_to do |format|
      format.json { render :add_to_cart }
    end

    # Analytics
    cart_item = Hash.new
    cart_item["context"] = context
    cart_item["position"] = position
    cart_item["recipes"] = product.id
    cart_item["sender_id"] = params[:user].to_i
    ahoy.track "add_to_cart", cart_item
  end

#http://localhost:3000/api/v1/card?recipe_id=123456&user=12345678
  def card
    profile = User.find_or_create_by(sender_id: params[:user])
    @recipe = Recipe.find(params[:recipe_id])
    respond_to do |format|
      format.json { render :card }
    end
  end



  #http://localhost:3000/api/v1/cart?user=1191499810899113
  def cart
    profile = User.find_or_create_by(sender_id: params[:user])
    @cart = Cart.find_or_create_by(user_id: profile.id)
    respond_to do |format|
      format.json { render :cart }
    end
  end



  #http://localhost:3000/api/v1/checkout?context=cart&user=12345678
  def checkout
    profile = User.find_or_create_by(sender_id: params[:user])
    type = "grocery list"
    cart = Cart.find_by(user_id: profile.id)

    @order = Order.create(user_id: cart.user_id, cart_id: cart.id, order_type: type, context: "cart")

    @order.order_cart_items

    respond_to do |format|
      format.json { render :checkout }
    end
  end

  #http://localhost:3000/api/v1/direct_checkout?product_id=123456&position=0&context=get_reco&user=1191499810899113
  def direct_checkout
    profile = User.find_or_create_by(sender_id: params[:user])
    product = Recipe.find(params[:product_id])
    position = params[:position]
    context = params[:context]
    type = "grocery list"

    @order = Order.create(user_id: profile.id, order_type: type, context: "direct_checkout")

    CartItemsController.create(name: product.title, productable_id: product.id, productable_type: product.class.name, quantity: 1, order_id: @order.id)

    respond_to do |format|
      format.json { render :checkout }
    end

    # Analytics
    direct_checkout = Hash.new
    direct_checkout["context"] = context
    direct_checkout["position"] = position
    direct_checkout["recipes"] = product.id
    direct_checkout["sender_id"] = params[:user].to_i
    ahoy.track "direct_checkout", direct_checkout
  end



  #http://localhost:3000/api/v1/order?order=123456&user=12345678
  def order
    @order = Order.find(params[:order])
    respond_to do |format|
      format.json { render :order }
    end

    # Analytics
    order = Hash.new
    order["order_id"] = @order.id
    order["type"] = @order.order_type
    order["context"] = @order.context
    order["sender_id"] = params[:user].to_i
    order["recipes"] = @order.recipes.map.with_index { |recipe, index| ["recipe_id_#{index}", recipe.id] }.to_h
    ahoy.track "order", order
  end



  #http://localhost:3000/api/v1/grocerylist?order=123456&user=12345678
  def grocerylist
    @order = Order.find(params[:order])
    @grocery_list = @order.send_grocery_list
    respond_to do |format|
      format.json { render :grocerylist }
    end
  end



    #http://localhost:3000/api/v1/profile?user=123456&username=test
  def profile
    @profile = User.find_or_create_by(sender_id: params[:user])
    @profile.username = params[:username]
    if @profile.email.empty? then @profile.email = "#{params[:user]}@foodmama.fr" end
    @profile.save
    respond_to do |format|
      format.json { render :profile }
    end
  end




  #http://localhost:3000/api/v1/get_sender_ids
  def get_sender_ids
    @users = User.get_sender_ids
    respond_to do |format|
      format.json { render :get_sender_ids }
    end
  end



  #http://localhost:3000/api/v1/destroy_user?user=123456
  def destroy_user
    @profile = User.find_or_create_by(sender_id: params[:user])
    @profile.destroy
    head :ok

    # Analytics
    ahoy.track "destroy_user", @profile
  end




## STANDBY

  #http://localhost:3000/api/v1/foodlist
  def foodlist
    list = FoodList.find_by(name: "vegetables", food_list_type: "pool").foods
    foods = Food.select_seasonal_food(list)
    @foodlist = FoodList.get_foodlist(foods)

    respond_to do |format|
      format.json { render :foodlist }
    end
  end

#http://localhost:3000/api/v1/set_cart_size?size=x&user=12345678
  def set_cart_size
    profile = User.find_or_create_by(sender_id: params[:user])
    cart = Cart.find_or_create_by(user_id: profile.id)
    cart.set_size(params[:size])
    head :ok
  end

  #http://localhost:3000/api/v1/remove_from_cart?product_id=123456&user=12345678
  def remove_from_cart
    profile = User.find_or_create_by(sender_id: params[:user])
    cart = Cart.find_by(user_id: profile.id)
    product = Recipe.find(params[:product_id])
    cart_item = CartItem.find_by(cart_id: cart.id, productable_id: product.id, productable_type: product.class.name)
    cart_item.destroy
    head :ok
  end

  #http://localhost:3000/api/v1/add_to_history?product_id=123456&user=12345678
#  def add_to_history
 #   profile = User.find_or_create_by(sender_id: params[:user])
  #  product = Recipe.find(params[:product_id])
   # RecipeList.add_to_user_history(profile, product)
    #head :ok
  #end

  #http://localhost:3000/api/v1/ban_recipe?product_id=123456&user=12345678
 # def ban_recipe
  #  profile = User.find_or_create_by(sender_id: params[:user])
   # product = Recipe.find(params[:product_id])
   # RecipeList.ban_recipe(profile, product)
   # head :ok
  #end


  #http://localhost:3000/api/v1/order_history?user=12345678
  def order_history
    profile = User.find_or_create_by(sender_id: params[:user])
    @order_history = profile.orders.reverse[0..9]
    respond_to do |format|
      format.json { render :order_history }
    end
  end


#http://localhost:3000/api/v1/recommend?type=salad&query=butternut+carottes&user=12345678
  def recommend
    # profile = User.find_by(sender_id: params[:user])
    # @recommendation = RecipeList.find_by(user_id: profile.id, recipe_list_type: "recommendation").recipe_list_items.first

    type = params[:type]
    query = params[:query].present? ? params[:query] : nil
    foods = Food.get_foods(query) if query

    content = foods.nil? ? Recipe.where(status: "published").tagged_with(type) : Recipe.search_by_food(type, foods)
    content = Recipe.where(status: "published").tagged_with(type) if content.empty?

    @recommendation = content.shuffle.first

    respond_to do |format|
      format.json { render :recommend }
    end
  end

  #http://localhost:3000/api/v1/recipelist?list=123456&user=12345678
  def recipelist
    @recipe_list = RecipeList.find(params[:list])
    respond_to do |format|
      format.json { render :recipelist }
    end
  end

  #http://localhost:3000/api/v1/diets?user=12345678
  def diets
    @diets = Diet.where(is_active: true)
    respond_to do |format|
      format.json { render :diets }
    end
  end

  #http://localhost:3000/api/v1/set_diet?diet=123&user=12345678
  def set_diet
    profile = User.find_or_create_by(sender_id: params[:user])
    diet = Diet.find(params[:diet])
    diet.update_user_diet(profile)
    head :ok
  end

  #http://localhost:3000/api/v1/user_diet?user=12345678
  def user_diet
    @profile = User.find_or_create_by(sender_id: params[:user])
    if @profile.diet.nil?
      @profile.diet = Diet.first
      @profile.save
    end
    respond_to do |format|
      format.json { render :user_diet }
    end
  end


  private
  def is_valid?
    @profile = User.find_by sender_id: params[:user]
    if @profile == nil
      return @user = false
    elsif @profile.beta == true
      return @user = true
    else
      return @user = false
    end
  end
end
