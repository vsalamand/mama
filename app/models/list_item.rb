class ListItem < ApplicationRecord
  belongs_to :list
  validates :name, presence: true
  has_many :items
  has_many :cart_items, through: :items
  has_many :food, through: :items

  accepts_nested_attributes_for :items

  #add a model scope to fetch only non-deleted records
  scope :not_deleted, -> { where(deleted: false) }
  scope :deleted, -> { where(deleted: true) }
  # scope to get list items in the lsit with no associated items
  scope :no_items, -> { includes(:items).where( deleted: false, :items => { :id => nil } ) }
  scope :to_validate, -> { includes(:items).where( :items => { :is_validated => false } ) }
  #add a model scope to fetch completed and uncompleted records
  scope :not_completed, -> { where(is_completed: false) }
  scope :completed, -> { where(is_completed: true) }



  #create the soft delete method
  def delete
    update(deleted: true)
    self.items.each{ |item| item.cart_items.destroy_all if item.cart_items.any? } if self.items.any?
  end

  # make an undelete method
  def undelete
    update(deleted: false)
  end

  # make a complete method
  def complete
    update(is_completed: true)
  end

  # make an uncomplete method
  def uncomplete
    update(is_completed: false)
  end

  def self.add_to_list(input, list)
    list_item = ListItem.new(name: input, list: list)
    valid_item = Item.where("lower(name) = ?", list_item.name.downcase).where(is_validated: true).first
    list_item.save
    # create new item or copy item if from recipe
    Thread.new do
      if valid_item.present?
        # Item.create(quantity: valid_item.quantity, unit: valid_item.unit, food: valid_item.food, list_item: @list_item, name: valid_item.name, is_validated: valid_item.is_validated)
        Item.create(food: valid_item.food, list_item: list_item, name: valid_item.food.name, is_validated: valid_item.is_validated)
      else
        new_item = Item.create_list_item(list_item)
        mail = ReportMailer.report_item(new_item)
        mail.deliver_now
      end
    end
  end
end
