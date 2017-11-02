class Api::V1::ActionsController < Api::V1::BaseController
#http://localhost:3000/api/v1/suggest
  def suggest
    @suggestions = []
    @suggestions << express = Recipe.search("express", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
    @suggestions << snack = Recipe.search("snack", operator: "or", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
    @suggestions << salad = Recipe.search("salade", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
    @suggestions << dish = Recipe.search("plat", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
    respond_to do |format|
      format.json { render :suggest }
    end
  end

# http://localhost:3000/api/v1/select?recipe=6
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
      Recipe.search(query)
    end
    respond_to do |format|
      format.json { render :search }
    end
  end
end
