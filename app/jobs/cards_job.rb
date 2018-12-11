class CardsJob < ApplicationJob
  queue_as :default

  def perform
    Recipe.where(status: "published").each do |recipe|
      recipe.upload_to_cloudinary
    end
  end
end
