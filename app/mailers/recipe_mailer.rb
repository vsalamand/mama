class RecipeMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.cart_mailer.share.subject
  #
  def send_menu(recipe_list, email)
    @recipe_list = recipe_list
    mail(to: email, subject: 'Votre menu')
  end

end
