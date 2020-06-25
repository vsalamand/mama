class ListMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.list_mailer.share.subject
  #
  def share(list, email, recipes)
    @list = list
    @email = email
    @recipes = recipes
    mail(to: @email, subject: "📝 #{list.name}")
  end

  def send_invite(list, email)
    @list = list
    @email = email
    mail(to: @email, subject: 'Vous avez reçu une invitation pour une liste de courses partagée')
  end
end
