class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods

  self.table_name = "ahoy_events"

  # if event is receipe view, we need to pass the user id otherwise ahoy can't find it
  after_create do
    self.user_id = User.find_or_create_by(sender_id: self.properties["sender_id"]).id if self.properties["sender_id"].present?
    self.save
  end


  belongs_to :visit
  belongs_to :user, optional: true
end
