class RecipeJob < ApplicationJob
  queue_as :default

  def perform
    Recipe.all.each do |recipe|
      recipe.rate
    end
  end
end
