class ListItem < ApplicationRecord
  belongs_to :list
  validates :name, presence: true
  has_one :item, dependent: :destroy
  has_many :cart_items, through: :item
  has_one :food, through: :item

  audited associated_with: :list


  accepts_nested_attributes_for :item

  #add a model scope to fetch only non-deleted records
  scope :not_deleted, -> { where(deleted: false) }
  scope :deleted, -> { where(deleted: true) }
  # scope to get list items in the lsit with no associated items
  scope :no_items, -> { includes(:item).where( deleted: false).where(:items => { :id => nil } ) }
  scope :to_validate, -> { includes(:items).where( :item => { :is_validated => false } ) }
  #add a model scope to fetch completed and uncompleted records
  scope :not_completed, -> { where(is_completed: false, deleted: false) }
  scope :completed, -> { where(is_completed: true, deleted: false) }

  after_create :broadcast_create
  after_update :broadcast_update

  def broadcast_create
    # render through broadcast cable
    data = {
             action: "create",
             list_item_id: self.id,
             message_partial_list: ApplicationController.renderer.render(partial: "lists/uncomplete_todo_list", locals: { list: self.list, list_item: self }),
             message_partial_form: ApplicationController.renderer.render(partial: "list_items/form", locals: { list: self.list, list_item: ListItem.new })
           }
    ListChannel.broadcast_to(
      "list_#{self.list.id}",
      data
    )
  end

  def broadcast_update
    if saved_change_to_is_completed? || saved_change_to_name?
      # # render through broadcast cable
      data = {
              list_item_id: self.id,
              message_partial: ApplicationController.renderer.render(partial: "list_items/show", locals: { list: self.list, list_item: self })
             }
      ListChannel.broadcast_to(
        "list_#{self.list.id}",
        data
      )
    elsif saved_change_to_deleted?
      # render through broadcast cable
      data = {
              action: "delete",
              list_item_id: self.id,
              store_section: self.get_store_section.parameterize(separator: ''),
              message_partial: ApplicationController.renderer.render(partial: "list_items/show", locals: { list: self.list, list_item: self })
            }
      ListChannel.broadcast_to(
        "list_#{self.list.id}",
        data
      )
    end
  end

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

  def get_item
    self.item
  end

  def self.add_menu_to_list(inputs_list, list)
    new_list_items = []
    new_validated_items = []

    inputs_list.each do |input|
      # process new list item
      list_item = ListItem.new(name: input, list: list)
      new_list_items << list_item

      # process new item
      valid_item = Item.where("lower(name) = ?", list_item.name.downcase).where(is_validated: true).first
      if valid_item.present?
        new_validated_items << Item.new(food: valid_item.food, list_item: list_item, name: list_item.name, is_validated: valid_item.is_validated, quantity: valid_item.quantity, unit: valid_item.unit, store_section_id: valid_item.store_section_id, is_non_food: valid_item.is_non_food)
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
    valid_item = Item.where("lower(name) = ?", self.name.downcase).where(is_validated: true).first
    valid_item.present? ? Item.create(food: valid_item.food, list_item: self, name: self.name, is_validated: valid_item.is_validated, quantity: valid_item.quantity, unit: valid_item.unit, store_section_id: valid_item.store_section_id, is_non_food: valid_item.is_non_food) : Item.add_list_items(Array(self))
  end

  def update_item(item)
    valid_item = Item.where("lower(name) = ?", self.name.downcase).where(is_validated: true).first
    if valid_item.present?
      item.update(food: valid_item.food, list_item: self, name: self.name, is_validated: valid_item.is_validated, quantity: valid_item.quantity, unit: valid_item.unit, store_section_id: valid_item.store_section_id, is_non_food: valid_item.is_non_food)
    else
      item.set(self)
    end
  end

  def get_store_section
    if self.item.present? && self.get_item.get_store_section.present?
      self.get_item.get_store_section.name
    else
      return "Autres"
    end
  end

  def get_food_name
    if self.food.present?
      return self.food.name
    else
      return self.name
    end
  end
end
