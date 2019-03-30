class Recommendation < ApplicationRecord
  belongs_to :user
  validates :name, :date, :user_id, presence: :true
end
