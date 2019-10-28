class CartMailerPreview < ActionMailer::Preview
  def share
    user = User.first
    # This is how you pass value to params[:user] inside mailer definition!
    CartMailer.share(user.cart, user.email)
  end
end
