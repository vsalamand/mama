class ListItem < ApplicationRecord
  belongs_to :list
  validates :name, presence: true
  has_one :item

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
