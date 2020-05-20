class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  # validates :sender_id, uniqueness: true
  # validates :username, uniqueness: true
  validates :email, uniqueness: true

  # validates :email, :uniqueness => {:allow_blank => true}
  belongs_to :diet, optional: true

  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :recipe_lists, dependent: :destroy
  has_many :foods, through: :orders
  has_many :recipes, through: :recipe_lists
  has_many :food_lists, dependent: :destroy
  has_many :lists, dependent: :destroy
  has_many :recipe_list_items, through: :lists
  has_many :collaborations
  has_many :shared_lists, through: :collaborations, source: :list

  has_many :visits, class_name: "Ahoy::Visit", dependent: :destroy
  has_many :events, class_name: "Ahoy::Event", dependent: :destroy


  after_create :subscribe_to_waiting_list
  after_create :send_welcome_email

  after_save do
    send_welcome_email_to_beta_user if self.beta_changed? && self.beta == true
  end

  def get_latest_list
    self.lists.where(status: "saved").last if self.lists.any?
  end

  def get_latest_recipe_list
    if self.recipe_lists.where(status: "opened").any?
      return self.recipe_lists.where(status: "opened").last
    else
      return RecipeList.create(user_id: self.id, recipe_list_type: "personal", status: "opened")
    end
  end


  private

  def subscribe_to_waiting_list
    SubscribeToWaitingList.new(self).call
  end

  def send_welcome_email
    mail = UserMailer.welcome(self)
    mail.deliver_now
  end

  def send_welcome_email_to_beta_user
    mail = UserMailer.welcome_beta(self)
    mail.deliver_now
  end


  protected
  def password_required?
    confirmed? ? super : false
  end
end
