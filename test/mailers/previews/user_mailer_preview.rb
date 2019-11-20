class UserMailerPreview < ActionMailer::Preview
  def welcome
    user = User.first
    # This is how you pass value to params[:user] inside mailer definition!
    UserMailer.welcome(user)
  end

  def waiting_list
    user = User.last
    # This is how you pass value to params[:user] inside mailer definition!
    UserMailer.waiting_list(user)
  end
end
