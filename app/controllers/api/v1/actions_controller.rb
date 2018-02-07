require 'date'

class Api::V1::ActionsController < Api::V1::BaseController
#http://localhost:3000/api/v1/suggest?date=-1
  def suggest
    date = params[:date].present? ? (Date.today + params[:date].to_i).strftime("%F") : Date.today.strftime("%F")
    RecommendationsController.create(date) if Recommendation.all.select { |reco| reco.recommendation_date == date }
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
      format.json { render :select
}    end
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
end
