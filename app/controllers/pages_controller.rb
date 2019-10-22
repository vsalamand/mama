class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]
  before_action :authenticate_admin!, only: [:dashboard, :pending]

  def home
    @list = List.new

    # if user is logged in, display the user grocery list
    if user_signed_in?
      if current_user.lists.any?
        list = current_user.lists.first
      else
        List.create(name: "Liste de courses", user_id: current_user.id)
      end
      redirect_to list_path(list)
    end
  end

  def profile
  end

  def confirmation
  end

  def dashboard
    @items_validation_size = ListItem.all.to_validate.size
    @list_items_verification_size = ListItem.all.no_items.size
    @reported_products = Product.where(is_reported: true).size

    @products = Product.all
    @no_food_products = Product.get_products_without_foods

    @foods = Food.all
    @foods_without_products = Food.get_foods_without_product
  end

  def pending
    @recipes = Recipe.where(status: "pending")
  end

  def unmatch_foods
    @foods_without_products = Food.get_foods_without_product
  end

  def unmatch_products
    @no_food_products = Product.get_products_without_foods
  end

  def verify_items
    @list_items = ListItem.all.to_validate
  end

  def verify_listitems
    @list_items = ListItem.all.no_items
  end

  def verify_products
    @products = Product.where(is_reported: true)
  end

  def seasonal
    @recipes = Recipe.where(status: "published").tagged_with("seasonal")
  end

  def uncategorized
    @recipes = Recipe.where(status: "published").tagged_with(["veggie", "salad", "pasta", "potato", "meat", "fish", "egg", "burger", "snack", "pizza"], :exclude => true)
  end

  def veggie
    @recipes = Recipe.where(status: "published").tagged_with("veggie")
  end

  def salad
    @recipes = Recipe.where(status: "published").tagged_with("salad")
  end

  def pasta
    @recipes = Recipe.where(status: "published").tagged_with("pasta")
  end

  def potato
    @recipes = Recipe.where(status: "published").tagged_with("potato")
  end

  def meat
    @recipes = Recipe.where(status: "published").tagged_with("meat")
  end

  def fish
    @recipes = Recipe.where(status: "published").tagged_with("fish")
  end

  def egg
    @recipes = Recipe.where(status: "published").tagged_with("egg")
  end

  def snack
    @recipes = Recipe.where(status: "published").tagged_with("snack")
  end

  def burger
    @recipes = Recipe.where(status: "published").tagged_with("burger")
  end

  def pizza
    @recipes = Recipe.where(status: "published").tagged_with("pizza")
  end

end
