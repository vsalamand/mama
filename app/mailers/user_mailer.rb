class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def welcome(user)
    @user = user # Instance variable => available in view
    mail(to: @user.email, subject: '👋 Vos listes de courses')
    # This will render a view in `app/views/user_mailer`!
  end

  def d1_feedback(user)
    @user = user # Instance variable => available in view
    mail(to: @user.email, subject: "👋 Votre liste de courses")
    # This will render a view in `app/views/user_mailer`!
  end

  def pmf_survey(user)
    @user = user # Instance variable => available in view
    mail(from: 'vincent@supernet.fr', to: @user.email, subject: 'Donnez nous votre avis 🙏')
  end

  def inactive_feedback(user)
    @user = user # Instance variable => available in view
    mail(from: 'vincent@supernet.fr', to: @user.email, subject: '👋 Vos listes de courses')
  end

  def welcome_beta(user)
    @user = user # Instance variable => available in view
    mail(to: @user.email, subject: 'Bienvenue !')
    # This will render a view in `app/views/user_mailer`!
  end

  def waiting_list(user)
    @user = user # Instance variable => available in view
    mail(to: @user.email, subject: "Merci pour votre inscription !")
    # This will render a view in `app/views/user_mailer`!
  end
end
