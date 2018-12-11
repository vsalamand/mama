class MetaRecipesJob < ApplicationJob
  queue_as :default

  def perform
    # Do something later
    MetaRecipe.all.each do |mr|
      mr.add_groups
    end
  end
end
