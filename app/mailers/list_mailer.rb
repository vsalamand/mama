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
end
