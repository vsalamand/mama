class RecipeList < ApplicationRecord
  belongs_to :user
  validates :name, :type, :user_id, presence: :true

  TYPE = ["mama", "personal", "automated"]

end
