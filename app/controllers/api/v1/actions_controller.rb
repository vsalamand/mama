class Api::V1::ActionsController < Api::V1::BaseController
#http://localhost:3000/api/v1/suggest
  def suggest
    @suggestions = []
    @suggestions << starter = Recipe.search("entrée snack", operator: "or", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
    @suggestions << light_dish = Recipe.search("accompagnement", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
    @suggestions << main_dish = Recipe.search("plat", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
    @suggestions << dessert = Recipe.search("dessert", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
    respond_to do |format|
      format.json { render :suggest }
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
