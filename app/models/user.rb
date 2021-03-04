class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # validates :sender_id, uniqueness: true
  # validates :username, presence: true, uniqueness: true, uniqueness: { case_sensitive: false }
  # validates_length_of :username, minimum: 2
  # validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true

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
    # self.set_initial_list
  end
  after_create :set_username
  after_create :subscribe_to_waiting_list
  after_save do
    set_username if self.saved_change_to_username?
  end
  # after_create :send_welcome_email

  # after_save do
  #   send_welcome_email_to_beta_user if self.beta_changed? && self.beta == true
  # end

 def correct_username(username)
    ActiveSupport::Inflector.transliterate(username) # change ñ => n
      .downcase              # only lower case
      .strip                 # remove spaces around the string
      .gsub(/[^a-z]/, '_')   # any character that is not a letter or a number will be _
      .gsub(/_+\Z/, '')      # remove underscores at the end
      .gsub(/_+/, '_')       # maximum an underscore in a row
      # .gsub(/\A_+/, '')      # remove underscores at the beginning
  end

 def find_unique_username(username)
    taken_usernames = User
      .where("username LIKE ?", "#{username}%")
      .pluck(:username)

    # username if it's free
    return username if ! taken_usernames.include?(username)

    count = 2
    while true
      # username_2, username_3...
      new_username = "#{username}_#{count}"
      return new_username if ! taken_usernames.include?(new_username)
      count += 1
    end
  end

  def set_username
    if self.username.nil? || self.username.empty? || self.username.size < 2
      username = self.email.split(/@/).first
      username = self.correct_username(username)
      username = self.find_unique_username(username)
      self.username = username
      self.save
    elsif self.username.count("A-Z") > 0 || !self.username[/\W/].nil? || User.find_by(username: self.username) != self
      username = self.username
      username = self.correct_username(username)
      username = self.find_unique_username(username)
      self.username = username
      self.save
    end
  end

  def add_to_beta
    self.beta = true
    self.save
  end

  def remove_beta
    self.beta = false
    self.save
  end

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

  def get_category_ids
    Item.where(list_id: self.get_lists.pluck(:id), is_completed: false, is_deleted: false).pluck(:category_id).compact
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

  def get_assistant
    List.find_or_create_by(name: "Assistant", user_id: self.id, status: "archived", list_type: "assistant", sorted_by: "rayon")
  end

  def get_dislikes_recipe_list
    RecipeList.find_or_create_by(name: "Dislikes", user_id: self.id, recipe_list_type: "dislikes", status: "archived")
  end

  def get_likes_recipe_list
    RecipeList.find_or_create_by(name: "Likes", user_id: self.id, recipe_list_type: "likes", status: "archived")
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

  def get_dislikes_list
    List.find_or_create_by(name: "Dislikes", user_id: self.id, status: "archived", list_type: "dislikes", sorted_by: "rayon")
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
