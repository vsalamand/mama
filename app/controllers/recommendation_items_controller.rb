class RecommendationItemsController < ApplicationController
  before_action :set_recommendation, only: [ :new, :create, :edit, :update ]
  before_action :set_recommendation_item, only: [ :edit, :update ]
  before_action :authenticate_admin!

  def new
    @recommendation_item = RecommendationItem.new
  end

  def create
    @recommendation_item = RecommendationItem.new(recommendation_item_params)
    @recommendation_item.recommendation = @recommendation
    if @recommendation_item.save
      redirect_to recommendation_path(@recommendation)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @recommendation_item.update(recommendation_item_params)
    redirect_to recommendation_path(@recommendation)
  end

  private
  def set_recommendation
    @recommendation = Recommendation.find(params[:recommendation_id])
  end

  def set_recommendation_item
    @recommendation_item = RecommendationItem.find(params[:id])
  end

  def recommendation_item_params
    params.require(:recommendation_item).permit(:recommendation_id, :recipe_list_id, :name) ## Rails 4 strong params usage
  end
end
