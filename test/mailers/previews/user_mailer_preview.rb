class UserMailerPreview < ActionMailer::Preview
  def welcome
    user = User.first
    # This is how you pass value to params[:user] inside mailer definition!
    UserMailer.welcome(user)
  end

  def d1_feedback
    user = User.first
    UserMailer.d1_feedback(user)
  end

  def pmf_survey
    user = User.first
    UserMailer.pmf_survey(user)
  end

  def waiting_list
    user = User.last
    # This is how you pass value to params[:user] inside mailer definition!
    UserMailer.waiting_list(user)
  end
end
