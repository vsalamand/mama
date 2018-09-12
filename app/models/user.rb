class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  validates :sender_id, uniqueness: true
  belongs_to :diet, optional: true

  has_one :cart
  has_many :orders
  has_many :recipe_lists
  has_many :foods, through: :orders

  after_create do
    Cart.create(user_id: self.id)
    RecipeList.create(name: "Weekly menu", user_id: self.id, recipe_list_type: "recommendation")
    RecipeList.create(name: "History", user_id: self.id, recipe_list_type: "history")
    RecipeList.create(name: "Banned recipes", user_id: self.id, recipe_list_type: "ban")
    # Update weekly recos for new user
    Recommendation.update_user_weekly_menu(self, Date.today.strftime("%W, %Y"))
  end
end
