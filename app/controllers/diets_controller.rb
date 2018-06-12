class DietsController < ApplicationController

  private
  def diets_params
    params.require(:diet).permit(:diet_id, :name, :description, :is_active)
  end
end
