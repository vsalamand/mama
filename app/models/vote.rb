class Vote < ApplicationRecord
  belongs_to :recipe_list_item
  belongs_to :user, optional: true
end
