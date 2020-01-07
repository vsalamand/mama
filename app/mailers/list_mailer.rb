class ListMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.list_mailer.share.subject
  #
  def share(list, email)
    @list = list
    mail(to: email, subject: 'Liste de courses')
  end

  def send_invite(list, email)
    @list = list
    @email = email
    mail(to: @email, subject: 'Vous avez reçu.e une invitation pour une liste de courses en commun')
  end
end
