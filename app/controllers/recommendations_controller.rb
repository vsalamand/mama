require 'date'

class RecommendationsController < ApplicationController

  def self.create(type, schedule)
    @recommendation = Recommendation.new
    @recommendation.recommendation_type = type
    @recommendation.schedule = schedule
    @recommendation.name = "Week #{schedule} | menu #{type}"
    @recommendation.save
    case type
      when "rapide" then Recommendation.create_express_menu(@recommendation)
      when "snack" then Recommendation.create_snack_menu(@recommendation)
      when "léger" then Recommendation.create_light_menu(@recommendation)
      when "tarte salée" then Recommendation.create_tart_menu(@recommendation)
      when "gourmand" then Recommendation.create_gourmet_menu(@recommendation)
    end
  end

  private
  def recommendation_params
    params.require(:recommendation).permit(:name, :schedule, :recommendation_type)
  end
end
