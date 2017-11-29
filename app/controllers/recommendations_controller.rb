require 'date'

class RecommendationsController < ApplicationController
  def self.create(date)
    @recommendations = Recommendation.new
    @recommendations.recommendation_date = date
    @recommendations.daily_reco = RecommendationsController.recommend
    @recommendations.save
  end

  private
  def self.recommend
    suggestions = []
    suggestions << Recipe.search("rapide", fields: [:tags], where: {status: "published"}).to_a.shuffle.take(1).first.id
    suggestions << Recipe.search("léger", fields: [:tags], where: {status: "published"}).to_a.shuffle.take(1).first.id
    suggestions << Recipe.search("snack", fields: [:tags], where: {status: "published"}).to_a.shuffle.take(1).first.id
    suggestions << Recipe.search("gourmand", fields: [:tags], where: {status: "published"}).to_a.shuffle.take(1).first.id
    return suggestions.join(', ')
  end
end