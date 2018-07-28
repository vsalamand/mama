class CardsJob < ApplicationJob
  queue_as :default

  def perform
    Recipe.all.each do |recipe|
      Recipe.upload_to_cloudinary(recipe)
    end
  end
end
