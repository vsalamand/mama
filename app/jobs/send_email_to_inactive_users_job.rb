class SendEmailToInactiveUsersJob < ApplicationJob
  queue_as :default

  def perform
    inactive_users  = []
    # Get users who created an account 7 days ago and did not visit again
    d7_users = User.where(created_at: 10.days.ago.beginning_of_day..10.days.ago.end_of_day)
    d7_inactive_users = d7_users.select{ |u| u.visits.size < 2  if u.visits.any? }
    inactive_users << d7_inactive_users

    unless Time.now.saturday? || Time.now.sunday?
      # Get users who created an account less than 28 days ago, where last visit was 14 days ago, and do not have the inactive flag
      d7_d28_users = User.where(created_at: 28.days.ago.beginning_of_day..7.days.ago.end_of_day)
      d7_d28_inactive_users = d7_d28_users.select{ |u| u.flags.pluck(:name).exclude?("inactive") && u.visits.last.started_at < 14.days.ago if u.visits.any? }
      inactive_users << d7_d28_inactive_users
      # Get users who have more than 7 visits and last visit was 21 days ago, and do not have the inactive flag
      other_inactive_users = User.select{ |u| u.flags.pluck(:name).exclude?("inactive") && u.visits.size > 7 && u.visits.last.started_at < 21.days.ago if u.visits.any? }
      inactive_users << other_inactive_users
    end

    # clean array of inactive users
    inactive_users = inactive_users.flatten.uniq

    inactive_users.each do |user|
      UserMailer.inactive_feedback(user).deliver_now
      Flag.create(name: "inactive", user_id: user.id)
    end

    puts "terminated - sent email to #{inactive_users.size} inactive user(s)"
  end
end
