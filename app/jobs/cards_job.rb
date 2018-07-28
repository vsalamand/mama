class CardsJob < ApplicationJob
  queue_as :default

  def perform
    Recipe.all.each |recipe|
      Recipe.upload_to_cloudinary(recipe)
    end
  end
end
