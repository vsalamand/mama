class UpdateInstructionsJob < ApplicationJob
  queue_as :default

  def perform
    # Do something later
    MetaRecipeList.where(list_type: "recipe").each do |mrl|
      mrl.update_instructions
    end
  end
end
