class CartMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.cart_mailer.share.subject
  #
  def share(cart, email)
    @cart = cart
    mail(from: cart.user.email, to: email, subject: 'Panier de courses')
  end
end
