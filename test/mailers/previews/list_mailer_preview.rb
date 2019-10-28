class ListMailerPreview < ActionMailer::Preview
  def share
    user = User.first
    # This is how you pass value to params[:user] inside mailer definition!
    ListMailer.share(user.lists.first, user.email)
  end
end
