class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  validates :sender_id, uniqueness: true
  belongs_to :diet

  has_one :cart
  has_many :orders
  has_many :recipe_lists
  has_many :foods, through: :orders
end
