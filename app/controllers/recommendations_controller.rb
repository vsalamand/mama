require 'date'

class RecommendationsController < ApplicationController
  def create
    @recommendations = Recommendation.new
    @recommendations.date = Date.today
    @recommendations.daily_reco = recommend

  end

  private
  def recommend
    suggestions = []
    suggestions << Recipe.search("équilibré", fields: [:tags], where: {status: "published"}).to_a.shuffle.take(1)
    suggestions << Recipe.search("rapide", fields: [:tags], where: {status: "published"}).to_a.shuffle.take(1)
    suggestions << Recipe.search("léger", fields: [:tags], where: {status: "published"}).to_a.shuffle.take(1)
    suggestions << Recipe.search("snack", fields: [:tags], where: {status: "published"}).to_a.shuffle.take(1)
    suggestions << Recipe.search("gourmand", fields: [:tags], where: {status: "published"}).to_a.shuffle.take(1)
  end
end
