require 'date'

class RecommendationsController < ApplicationController

  def self.create(type, schedule)
    @recommendation = Recommendation.new
    @recommendation.recommendation_type = type
    @recommendation.schedule = schedule
    @recommendation.name = "Week #{schedule} | #{type}"
    @recommendation.save
    case type
      when "classique" then Recommendation.create_classic_basket(@recommendation)
      when "express" then Recommendation.create_express_basket(@recommendation)
      when "gourmand" then Recommendation.create_gourmand_basket(@recommendation)
    end
  end

  private
  def recommendation_params
    params.require(:recommendation).permit(:name, :schedule, :recommendation_type)
  end
end
