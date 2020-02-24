class RecipeJob < ApplicationJob
  queue_as :default

  def perform(csv)
    Recipe.import_csv(csv)
  end
end
