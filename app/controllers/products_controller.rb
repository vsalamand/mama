class ProductsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show ]

  def show
    @product = Product.find(params[:id])
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    @product.update(products_params)
    # redirect_back(fallback_location:"/")
    render 'update.js.erb'
  end

  def report
    product = StoreItem.find(params[:format]).product
    product.report
    if params[:cart_id].present?
      @cart = Cart.find(params[:cart_id])
      @cart_item = CartItem.find(params[:cart_item_id])
      @food = StoreItem.find(params[:format]).food
      render "cart_report.js.erb"
    elsif params[:list_id].present?
      @list = List.find(params[:list_id])
      @list_item = ListItem.find(params[:list_item_id])
      @food = StoreItem.find(params[:format]).food
      render "list_report.js.erb"
    end
    mail = ReportMailer.report_product(product)
    mail.deliver_now
  end

  def search
    @food = Food.find(params[:format])
    if params[:cart_id].present?
      @cart = Cart.find(params[:cart_id])
      @cart_item = CartItem.find(params[:cart_item_id])
      @item = @cart_item.item
      render "cart_search.js.erb"
    elsif params[:list_id].present?
      @list = List.find(params[:list_id])
      @list_item = ListItem.find(params[:list_item_id])
      @item = @list_item.items.last
      render "list_search.js.erb"
    end
  end

  def advanced_search
    query = params[:query].present? ? params[:query] : nil
    store_id = params[:store].present? ? params[:store]['id'] : nil
    food_id = params[:food].present? ? params[:food]['id'] : nil

    if store_id.present? && food_id.present?
      @food = Food.find(food_id)
      @results = Product.search("*", page: params[:page], per_page: 50, aggs: [:stores], where: {stores: Store.find(store_id).name, food_id: @food.id})

    elsif query && store_id.present?
      @results = Product.search(query, page: params[:page], per_page: 50, aggs: [:stores], where: {stores: Store.find(store_id).name})

    elsif food_id.present?
      @food = Food.find(food_id)
      @results = Product.search("*", page: params[:page], per_page: 50, aggs: [:stores], where: {food_id: @food.id})

    else
      @results = Product.search(query, page: params[:page], per_page: 50, aggs: [:stores]) if query
    end
    # @results = search.zip(search.hits.map{ |hit| hit["_score"] }) if search
  end

  def index
    query = params[:query].present? ? params[:query] : nil
    store_id = params[:store].present? ? params[:store]['id'] : nil
    food_id = params[:food].present? ? params[:food]['id'] : nil

    if store_id.present? && food_id.present?
      @food = Food.find(food_id)
      @results = Product.search("*", page: params[:page], per_page: 50, aggs: [:stores], where: {stores: Store.find(store_id).name, food_id: @food.id})

    elsif query && store_id.present?
      @results = Product.search(query, page: params[:page], per_page: 50, aggs: [:stores], where: {stores: Store.find(store_id).name})

    elsif food_id.present?
      @food = Food.find(food_id)
      @results = Product.search("*", page: params[:page], per_page: 50, aggs: [:stores], where: {food_id: @food.id})

    else
      @results = Product.search(query, page: params[:page], per_page: 50, aggs: [:stores]) if query
    end

  end

  def edit_multiple
    @products = Product.find(params[:product_ids])
  end

  def update_multiple
    @products = Product.find(params[:product_ids])
    @products.each{ |product| product.update(products_params)}
    redirect_to products_path
  end

  private
  def products_params
    params.require(:product).permit(:id, :food_id, :ean, :name, :quantity, :unit_id, :brand, :origin, :is_frozen, :is_reported)
  end
end
