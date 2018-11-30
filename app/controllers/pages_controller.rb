class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :search, :confirmation]

  def home
  end

  def confirmation
  end

  def dashboard
    @recipes = Recipe.where(status: "published")
    @seasonal = Recipe.where(status: "published").tagged_with("seasonal")
    @no_category = Recipe.where(status: "published").tagged_with(["veggie", "salad", "pasta", "potato", "meat", "fish", "egg", "burger", "snack", "pizza"], :exclude => true)

    @veggie = Recipe.where(status: "published").tagged_with("veggie")
    @salad = Recipe.where(status: "published").tagged_with("salad")
    @pasta = Recipe.where(status: "published").tagged_with("pasta")
    @potato = Recipe.where(status: "published").tagged_with("potato")
    @meat = Recipe.where(status: "published").tagged_with("meat")
    @fish = Recipe.where(status: "published").tagged_with("fish")
    @egg = Recipe.where(status: "published").tagged_with("egg")
    @snack = Recipe.where(status: "published").tagged_with("snack")
    @burger = Recipe.where(status: "published").tagged_with("burger")
    @pizza = Recipe.where(status: "published").tagged_with("pizza")

    @meta_recipes = MetaRecipe.all
    @mr_pools = MetaRecipeList.where(list_type: "pool").sort_by { |pool| pool.meta_recipes.count}.reverse
  end

  def pending
    @recipes = Recipe.where(status: "pending")
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
