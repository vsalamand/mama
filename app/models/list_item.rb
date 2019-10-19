class ListItem < ApplicationRecord
  belongs_to :list
  validates :name, presence: true
  has_many :items
  has_many :cart_items, through: :items
  has_one :food, through: :items

  accepts_nested_attributes_for :items

  #add a model scope to fetch only non-deleted records
  scope :not_deleted, -> { where(deleted: false) }
  scope :deleted, -> { where(deleted: true) }
  # scope to get list items in the lsit with no associated items
  scope :no_items, -> { includes(:items).where( deleted: false, :items => { :id => nil } ) }



  #create the soft delete method
  def delete
    update(deleted: true)
    self.items.each{ |item| item.cart_item.destroy if item.cart_item.present? } if self.items.any?
  end

  # make an undelete method
  def undelete
    update(deleted: false)
  end
end
