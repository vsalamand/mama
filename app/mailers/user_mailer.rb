class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def welcome(user)
    @user = user # Instance variable => available in view
    mail(to: @user.email, subject: 'Retrouvez vos listes de courses Mama')
    # This will render a view in `app/views/user_mailer`!
  end

  def welcome_beta(user)
    @user = user # Instance variable => available in view
    mail(to: @user.email, subject: 'Bienvenue sur Mama !')
    # This will render a view in `app/views/user_mailer`!
  end

  def waiting_list(user)
    @user = user # Instance variable => available in view
    mail(to: @user.email, subject: "Merci pour votre inscription !")
    # This will render a view in `app/views/user_mailer`!
  end
end
