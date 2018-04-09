require 'date'

class Api::V1::ActionsController < Api::V1::BaseController
  before_action :is_valid?, only: [:suggest, :select, :search, :recommend]
#http://localhost:3000/api/v1/suggest?date=-1&user=12345678
  def suggest
    date = params[:date].present? ? (Date.today + params[:date].to_i) : Date.today
    RecommendationsController.create(date) unless Recommendation.where(recommendation_date: date).present?
    @suggestions = Recommendation.all.select { |reco| reco.recommendation_date == date }.first.daily_reco.split(',')
    respond_to do |format|
      format.json { render :suggest }
    end
  end

#http://localhost:3000/api/v1/select?recipe=6&user=12345678
  def select
    if params[:recipe].present?
      @recipe = Recipe.find(params[:recipe])
    end
    respond_to do |format|
      format.json { render :select }
    end
  end

#http://localhost:3000/api/v1/search?query=snack+citron+cru&user=12345678
  def search
    query = params[:query].present? ? params[:query] : nil
    @search = if query
      Recipe.search(query, fields: [:title, :ingredients, :tags], where: {status: "published"})[0..4]
    end
    respond_to do |format|
      format.json { render :search }
    end
  end

#http://localhost:3000/api/v1/recommend?type=rapide&user=12345678
  def recommend
    type = params[:type]
    @recommendation = Recipe.find(RecommendationsController.recommend(type))
    respond_to do |format|
      format.json { render :recommend }
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

  #http://localhost:3000/api/v1/add_to_cart?product_id=123456&user=12345678
  def add_to_cart
    profile = User.find_by(sender_id: params[:user])
    @cart = Cart.find_or_create_by(user_id: profile.id)
    product = Recipe.find(params[:product_id])
    CartItemsController.create(name: product.title, productable_id: product.id, productable_type: product.class.name, quantity: 1, cart_id: @cart.id)
    respond_to do |format|
      format.json { render :add_to_cart }
    end
  end

  #http://localhost:3000/api/v1/remove_from_cart?product_id=123456&user=12345678
  def remove_from_cart
    profile = User.find_by(sender_id: params[:user])
    cart = Cart.find_by(user_id: profile.id)
    product = Recipe.find(params[:product_id])
    cart_item = CartItem.find_by(cart_id: cart.id, productable_id: product.id, productable_type: product.class.name)
    cart_item.destroy
    head :ok
  end

  #http://localhost:3000/api/v1/cart?user=12345678
  def cart
    profile = User.find_by(sender_id: params[:user])
    @cart = Cart.find_or_create_by(user_id: profile.id)
    respond_to do |format|
      format.json { render :cart }
    end
  end

  #http://localhost:3000/api/v1/checkout?user=12345678
  def checkout
    profile = User.find_by(sender_id: params[:user])
    cart = Cart.find_by(user_id: profile.id)
    type = "Grocery list"
    @order = Order.create(user_id: cart.user_id, cart_id: cart.id, order_type: type)
    @order.order_cart_items
    respond_to do |format|
      format.json { render :checkout }
    end
  end

  #http://localhost:3000/api/v1/order?order=123456&user=12345678
  def order
    @order = Order.find(params[:order])
    respond_to do |format|
      format.json { render :order }
    end
  end

  #http://localhost:3000/api/v1/order_history?user=12345678
  def order_history
    profile = User.find_by(sender_id: params[:user])
    @order_history = profile.orders.reverse[0..9]
    respond_to do |format|
      format.json { render :order_history }
    end
  end

  #http://localhost:3000/api/v1/grocerylist?order=123456&user=12345678
  def grocerylist
    @order = Order.find(params[:order])
    @grocery_list = @order.send_grocery_list
    respond_to do |format|
      format.json { render :grocerylist }
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
