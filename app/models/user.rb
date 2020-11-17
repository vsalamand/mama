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
    List.find_or_create_by(name: "Dislikes", user_id: self.id, status: "archived", list_type: "personal", sorted_by: "rayon")
  end

  def create_score(game)
    Score.find_or_create_by(user: self, game: game)
  end

  def recommended_categories
    data = []

    user_history = Item.where(['created_at > ?', 7.days.ago])
                        .where(list_id: self.get_lists.pluck(:id))
                        .pluck(:category_id)
                        .uniq
                        .compact
    seasonings = Category.get_seasonings
    snoozed = Item.where(list_id: self.get_dislikes_list).pluck(:category_id)
    banned_products = user_history + seasonings + snoozed


    user_tops = Item.where(['created_at > ?', 30.days.ago])
                    .where(list_id: self.get_lists.pluck(:id))
                    .pluck(:category_id)
                    .group_by{|x| x}.sort_by{|k, v| -v.size}
                    .map(&:first)
                    .compact

    user_tops = (user_tops - user_history - snoozed).map{|id| {id: id, context: "user_top"}}.each_slice(3).to_a
    data << user_tops

    recipe_tops = Item.where(recipe_id: Recipe.where(['created_at > ?', 45.days.ago]).where(status: "published").pluck(:id))
                      .pluck(:category_id)
                      .group_by{|x| x}
                      .sort_by{|k, v| -v.size}
                      .map(&:first)
                      .compact

    recipe_tops = (recipe_tops - banned_products).map{|id| {id: id, context: "recipe_top"}}.each_slice(3).to_a
    data << recipe_tops

    global_tops = Item.where(['created_at > ?', 30.days.ago])
                      .where.not(list_id: nil)
                      .pluck(:category_id)
                      .group_by{|x| x}
                      .sort_by{|k, v| -v.size}
                      .map(&:first)
                      .compact

    global_tops = (global_tops - banned_products).map{|id| {id: id, context: "global_top"}}.each_slice(2).to_a
    data << global_tops

    # Checklist.find_by(name: "healthy").checklist_items.each do |checklist|
    #   category_ids = checklist.list.categories.pluck(:id)
    #   data << (category_ids - banned_products).map{|id| {id: id, context: "recommended"}}.each_slice(2).to_a if (user_history & category_ids).empty?
    # end

    data = data.select(&:present?)
    data = data.first.zip(*data[1..])
                    .flatten
                    .compact
                    .uniq! {|e| e[:id] }
                    # .group_by { |item| item[:id] }
                    # .map{ |arr| arr.second.reduce(&:merge)}
                    # .each_slice(1).to_a
    # return array of hashes
    return data
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
