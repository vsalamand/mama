class ListItem < ApplicationRecord
  belongs_to :list
  validates :name, presence: true
  has_many :items
  has_one :food, through: :items

  accepts_nested_attributes_for :items

  #add a model scope to fetch only non-deleted records
  scope :not_deleted, -> { where(deleted: false) }
  scope :deleted, -> { where(deleted: true) }


  #create the soft delete method
  def delete
    update(deleted: true)
  end

  # make an undelete method
  def undelete
    update(deleted: false)
  end
end
