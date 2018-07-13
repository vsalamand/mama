class Diet < ApplicationRecord
  validates :name, presence: :true
  has_many :food_lists
  has_many :checklists
  has_many :recipe_lists
  has_many :recommendations
  has_many :users
  has_many :banned_categories
  has_many :categories, through: :banned_categories
  has_many :banned_foods
  has_many :foods, through: :banned_foods

  after_create do
    FoodList.create(name: "Diet banned food list | #{self.name}", diet_id: self.id, food_list_type: "ban")
    FoodList.update_banned_foods(self)
    RecipeList.create(name: "Diet seasonal recipes | #{self.name}", diet_id: self.id, recipe_list_type: "pool")
    RecipeList.update_recipe_pools
    RecommendationsController.create(self, Date.today.strftime("%W, %Y"))
  end

  def self.update_user_diet(user, diet)
    if user.diet != diet
      user.diet_id = diet.id
      user.save
      schedule = Date.today.strftime("%W, %Y")
      # onc diet is changed, user recommendations must be recomputed to match the new constraints
      Recommendation.update_user_weekly_menu(user, schedule)
    end
  end
end
