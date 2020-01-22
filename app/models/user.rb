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
  has_many :collaborations
  has_many :shared_lists, through: :collaborations, source: :list

  has_many :visits, class_name: "Ahoy::Visit", dependent: :destroy
  has_many :events, class_name: "Ahoy::Event", dependent: :destroy


  after_create :subscribe_to_waiting_list
  after_create :send_welcome_email_to_waiting_list_users


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

  def get_menu
    menu = self.recipe_lists.where(status: "opened").last
    if menu.nil?
      menu = RecipeList.create(name: "Menu du #{Date.today.strftime("%d/%m/%Y")}",
                                user_id: self.id,
                                recipe_list_type: "personal",
                                status: "opened")
    end
    return menu
  end


  private

  def subscribe_to_waiting_list
    SubscribeToWaitingList.new(self).call
  end

  def send_welcome_email_to_waiting_list_users
    mail = UserMailer.waiting_list(self)
    mail.deliver_now
  end


  protected
  def password_required?
    confirmed? ? super : false
  end
end
