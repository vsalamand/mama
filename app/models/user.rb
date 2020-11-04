class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # validates :sender_id, uniqueness: true
  # validates :username, uniqueness: true
  validates :email, presence: true, uniqueness: true

  # validates :email, :uniqueness => {:allow_blank => true}
  belongs_to :diet, optional: true

  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :recipe_lists, dependent: :destroy
  has_many :foods, through: :orders
  has_many :recipes, through: :recipe_lists
  has_many :food_lists, dependent: :destroy
  has_many :lists, dependent: :destroy
  has_many :items, through: :lists
  has_many :recipe_list_items, through: :lists
  has_many :collaborations, dependent: :destroy
  has_many :shared_lists, through: :collaborations, source: :list
  has_many :flags, dependent: :destroy
  has_many :scores

  has_many :visits, class_name: "Ahoy::Visit", dependent: :destroy
  has_many :events, class_name: "Ahoy::Event", dependent: :destroy


  after_create do
    self.create_score(Game.first)
    self.set_initial_list
  end
  after_create :subscribe_to_waiting_list
  # after_create :send_welcome_email

  # after_save do
  #   send_welcome_email_to_beta_user if self.beta_changed? && self.beta == true
  # end

  def get_latest_list
    self.lists.where(status: "saved").last if self.lists.any?
  end

  def get_current_list
    flag = Flag.find_or_create_by(name: "current_list", user_id: self.id)
    return  flag.data.present? ? List.find(flag.data.to_i) : nil
  end

  def reset_current_list
    $path = "/browse"
    flag = Flag.find_or_create_by(name: "current_list", user_id: self.id)
    flag.data = nil
    flag.save
  end

  def set_current_list(list_id)
    flag = Flag.find_or_create_by(name: "current_list", user_id: self.id)
    flag.data = list_id
    flag.save
  end

  def get_lists
    return self.lists.saved + self.shared_lists.saved
  end

  def get_score
    self.scores.first.value
  end

  def get_items
    self.items.where(list_id: self.get_lists.pluck(:id))
  end

  def set_initial_list
    list = List.new
    list.name = self.set_new_list_name
    list.user_id = self.id
    list.sorted_by = "rayon"
    list.status = "saved"
    list.list_type == "personal"
    list.save
    list.set_game
  end

  def get_latest_recipe_list
    if self.recipe_lists.where(status: "opened").any?
      return self.recipe_lists.where(status: "opened").last
    else
      return RecipeList.create(user_id: self.id, recipe_list_type: "personal", status: "opened")
    end
  end

  def set_new_list_name
    count = self.get_lists.size
    if count == 0
      return "Liste de courses"
    else
      return "Liste de courses #{count + 1}"
    end
  end

  def create_score(game)
    Score.find_or_create_by(user: self, game: game)
  end


  private

  def subscribe_to_waiting_list
    begin
      SubscribeToWaitingList.new(self).call if Rails.env.production?
    rescue => e
      print e
    end
  end

  def send_welcome_email
    mail = UserMailer.welcome(self)
    mail.deliver_now
  end

  def send_welcome_email_to_beta_user
    mail = UserMailer.welcome_beta(self)
    mail.deliver_now
  end


end
