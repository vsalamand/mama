class List < ApplicationRecord
  belongs_to :user
  has_many :list_items, dependent: :destroy
  has_many :items, through: :list_items
  has_many :foods, through: :items
  validates :name, presence: true

end
