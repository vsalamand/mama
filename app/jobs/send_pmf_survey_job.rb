class SendPmfSurveyJob < ApplicationJob
  queue_as :default

  def perform
    # users who visited the app yesterday
    yesterday_user_ids = Ahoy::Visit.where(started_at: Date.yesterday.beginning_of_day..Date.yesterday.end_of_day)
                      .where.not(user_id: nil)
                      .pluck(:user_id)
                      .uniq
    yesterday_users = User.find(yesterday_user_ids)

    #  do not have a flag "pmf_survey" && user created more than 3 weeks ago
    target_yesterday_users = yesterday_users.select{ |u| u.flags.pluck(:name).exclude?("pmf_survey") && u.created_at < (Date.today.beginning_of_day - 21.days) }

    # visited the app at least 5 times
    users = target_yesterday_users.select{ |u| u.visits.size > 4 if u.visits.any? }

    users.each do |user|
      UserMailer.pmf_survey(user).deliver_now
      Flag.create(name: "pmf_survey", user_id: user.id)
    end

    puts "terminated - sent #{users.size} pmf survey(s)"
  end
end
