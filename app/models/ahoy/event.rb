class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods

  self.table_name = "ahoy_events"

  # if event is receipe view, we need to pass the user id otherwise ahoy can't find it
  after_create do
    self.user_id = self.properties["user_id"] if self.properties["user_id"].present? && self.name == "recipe_view"
    self.save
  end


  belongs_to :visit
  belongs_to :user, optional: true
end
