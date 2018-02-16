require 'date'

class Api::V1::ActionsController < Api::V1::BaseController
#http://localhost:3000/api/v1/suggest?date=-1
  def suggest
    date = params[:date].present? ? (Date.today + params[:date].to_i) : Date.today
    RecommendationsController.create(date) unless Recommendation.where(recommendation_date: date).present?
    @suggestions = Recommendation.all.select { |reco| reco.recommendation_date == date }.first.daily_reco.split(',')
    respond_to do |format|
      format.json { render :suggest }
    end
  end

#http://localhost:3000/api/v1/select?recipe=6
  def select
    if params[:recipe].present?
      @recipe = Recipe.find(params[:recipe])
    end
    respond_to do |format|
      format.json { render :select }
    end
  end

#http://localhost:3000/api/v1/search?query=snack+citron+cru
  def search
    query = params[:query].present? ? params[:query] : nil
    @search = if query
      Recipe.search(query, where: {status: "published"})
    end
    respond_to do |format|
      format.json { render :search }
    end
  end

#http://localhost:3000/api/v1/recommend?type=rapide
  def recommend
    type = params[:type]
    @recommendation = Recipe.find(RecommendationsController.recommend(type))
    respond_to do |format|
      format.json { render :recommend }
    end
  end

#http://localhost:3000/api/v1/profile?sender_id=123456&username=test
  def profile
    @profile = User.find_or_create_by(sender_id: params[:sender_id])
    @profile.username = params[:username]
    @profile.save
    respond_to do |format|
      format.json { render :profile }
    end
  end
end
