class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def welcome(user)
    @user = user # Instance variable => available in view
    mail(to: @user.email, subject: '👋 Vos listes de courses Mama')
    # This will render a view in `app/views/user_mailer`!
  end

  def d1_feedback(user)
    @user = user # Instance variable => available in view
    mail(from: 'vincent@clubmama.co', to: @user.email, subject: 'Premiers pas sur Mama')
    # This will render a view in `app/views/user_mailer`!
  end

  def pmf_survey(user)
    @user = user # Instance variable => available in view
    mail(from: 'vincent@clubmama.co', to: @user.email, subject: 'Que pensez-vous de Mama ?')
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
