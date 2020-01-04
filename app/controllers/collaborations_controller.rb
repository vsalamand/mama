class CollaborationsController < ApplicationController
  def create
    @list = List.find(params[:list_id])
    @user = User.where('email LIKE ?', "%#{params[:search]}%")
              .first
    # if @user
    #   @collaboration = Collaboration.new(list: @list, user: @user)
    #   if @collaboration.save
    #     flash[:notice] = "L'invitation a été envoyée !"
    #   else
    #     flash[:error] = "L'application a rencontré un problème."
    #   end
    # else
    #   flash[:error] = "Une invitation a été envoyée à l'adresse email indiquée !"
    # end
    redirect_to @list
  end
end
