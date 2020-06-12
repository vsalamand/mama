class Day1feedbackJob < ApplicationJob
  queue_as :default

  def perform
    # Do something later
    users = User.where(created_at: Date.yesterday.beginning_of_day..Date.yesterday.end_of_day)
    users.each{ |user| UserMailer.d1_feedback(user).deliver_now }
    puts "terminated - sent #{users.size} email(s)"
  end
end
