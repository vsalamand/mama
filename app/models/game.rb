class Game < ApplicationRecord
  has_many :tasks
  has_many :lists
end
