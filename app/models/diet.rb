class Diet < ApplicationRecord
  validates :name, presence: :true
  has_many :food_lists
  has_many :checklists
  has_many :recipe_lists
  has_many :recommendations
  has_many :users

  def self.update_user_diet(user, diet)
    if user.diet =! diet
      user.diet = diet
      user.save
      schedule = Date.today.strftime("%W, %Y")
      # onc diet is changed, user recommendations must be recomputed to match the new constraints
      Recommendation.update_user_weekly_menu(user, schedule)
    end
  end
end
