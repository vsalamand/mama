class ListItem < ApplicationRecord
  belongs_to :list
  validates :name, presence: true
  has_many :items, dependent: :destroy
  has_many :cart_items, through: :items
  has_many :food, through: :items

  accepts_nested_attributes_for :items

  #add a model scope to fetch only non-deleted records
  scope :not_deleted, -> { where(deleted: false) }
  scope :deleted, -> { where(deleted: true) }
  # scope to get list items in the lsit with no associated items
  scope :no_items, -> { includes(:items).where( deleted: false).where(:items => { :id => nil } ) }
  scope :to_validate, -> { includes(:items).where( :items => { :is_validated => false } ) }
  #add a model scope to fetch completed and uncompleted records
  scope :not_completed, -> { where(is_completed: false, deleted: false) }
  scope :completed, -> { where(is_completed: true, deleted: false) }

  scope :has_many_items, -> { joins(:items).group('list_items.id').having('count(items) > 1') }



  #create the soft delete method
  def delete
    update(deleted: true)
    # self.items.each{ |item| item.cart_items.destroy_all if item.cart_items.any? } if self.items.any?
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

  def self.add_menu_to_list(inputs_list, list)
    new_list_items = []
    new_validated_items = []

    inputs_list.each do |input|
      # process new list item
      list_item = ListItem.new(name: input, list: list)
      new_list_items << list_item

      # process new item
      valid_item = Item.where("lower(name) = ?", list_item.name.downcase.strip).where(is_validated: true).first
      if valid_item.present?
        new_validated_items << Item.new(food: valid_item.food, list_item: list_item, name: list_item.name, is_validated: valid_item.is_validated, quantity: valid_item.quantity, unit: valid_item.unit)
      end
    end

    # create all list items
    list_items = ListItem.import new_list_items
    # create all validated items
    Item.import new_validated_items
    # create all unvalidated items
    Item.add_list_items(ListItem.find(list_items["ids"]))
  end

  def self.add_to_list(input, list)
    list_item = ListItem.new(name: input, list: list)
    list_item.save
    Thread.new do
      list_item.create_or_copy_item
    end
  end

  def create_or_copy_item
    valid_item = Item.where("lower(name) = ?", self.name.downcase.strip).where(is_validated: true).first
    valid_item.present? ? Item.create(food: valid_item.food, list_item: self, name: self.name, is_validated: valid_item.is_validated, quantity: valid_item.quantity, unit: valid_item.unit) : Item.add_list_items(Array(self))
  end
end
