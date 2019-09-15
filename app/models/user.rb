class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  validates :sender_id, uniqueness: true
  validates :email, :uniqueness => {:allow_blank => true}
  belongs_to :diet, optional: true

  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :recipe_lists, dependent: :destroy
  has_many :foods, through: :orders
  has_many :recipes, through: :orders
  has_many :food_lists, dependent: :destroy

  has_many :visits, class_name: "Ahoy::Visit", dependent: :destroy
  has_many :events, class_name: "Ahoy::Event", dependent: :destroy


  after_create do
    Cart.create(user_id: self.id)

    # RecipeList.create(name: "Banned recipes", user_id: self.id, recipe_list_type: "ban")
    #RecipeList.create(name: "Weekly menu", user_id: self.id, recipe_list_type: "recommendation")
    #RecipeList.create(name: "History", user_id: self.id, recipe_list_type: "history")
    # # Update weekly recos for new user !!!!!!=> will be done wdurin set_diet process
    # Recommendation.update_user_weekly_menu(self, Date.today.strftime("%W, %Y"))
  end

  def self.get_sender_ids
    sender_ids = []
    User.all.order(:id).each { |user| sender_ids << user.sender_id if user.sender_id.present? && user.sender_id.scan(/\D/).empty? }
    return sender_ids
  end

  def self.check_or_create_user(sender_id, username)
    profile = User.find_by(sender_id: sender_id)
    if profile.nil?
      profile = User.create(sender_id: sender_id, username: username, email: "#{sender_id}@foodmama.fr")
      profile.save
    end
    return profile
  end
end
