class SendPmfSurveyJob < ApplicationJob
  queue_as :default

  def perform
    # users who visited the app yesterday
    yesterday_user_ids = Ahoy::Visit.where(started_at: Date.yesterday.beginning_of_day..Date.yesterday.end_of_day)
                      .where.not(user_id: nil)
                      .pluck(:user_id)
                      .uniq
    yesterday_users = User.find(yesterday_user_ids)

    #  do not have a flag "pmf_survey" && user created more than 2 weeks ago
    target_yesterday_users = yesterday_users.select{ |u| u.flags.exclude?("pmf_survey") && u.created_at < (Date.today.beginning_of_day - 14.days) }

    # visited the app at least 7 times
    users = target_yesterday_users.select{ |u| u.visits.size > 6 if u.visits.any? }

    users.each{ |user| UserMailer.pmf_survey(user).deliver_now }
    puts "terminated - sent #{users.size} pmf survey(s)"
  end
end
