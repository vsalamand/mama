class RecommendationsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @recommendations = Recommendation.all
  end

  def show
    @recommendation = Recommendation.find(params[:id])
    @recommendation.recommendation_items.build
  end

  def new
    @recommendation = Recommendation.new
  end

  def create
    @recommendation = Recommendation.new(recommendation_params)
    if @recommendation.save
      redirect_to recommendation_path(@recommendation)
    else
      redirect_to new_recommendation_path
    end
  end

  def edit
    @recommendation = Recommendation.find(params[:id])
  end

  def update
    @recommendation = Recommendation.find(params[:id])
    @recommendation.update(recommendation_params)
    redirect_to recommendation_path(@recommendation)
  end

  def publish
    @recommendation = Recommendation.find(params[:id])
    @recommendation.set_active
    redirect_to recommendation_path(@recommendation)
  end

  private
  def recommendation_params
    params.require(:recommendation).permit(:name, :date, :description, :is_active, :image_url, :link, :user_id, recipe_list_ids: [])
  end
end
