class Store < ApplicationRecord
  belongs_to :merchant

  STORE_TYPE = ["online", "physical"]

end
