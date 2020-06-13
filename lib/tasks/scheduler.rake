desc "send day1 user a customer feedback email from founder"
task send_day1_email: :environment do
  puts "Sending email from founder to day 1 users..."
  Day1feedbackJob.perform_now
  puts "ok !"
end

desc "send PMF survey to targeted user who visited yesterday"
task send_pmf_survey_email: :environment do
  puts "Sending PMF survey emails..."
  SendPmfSurveyJob.perform_now
  puts "ok !"
end

desc "send email to inactive users"
task send_email_to_inactive_users: :environment do
  puts "Sending PMF survey emails..."
  SendEmailToInactiveUsersJob.perform_now
  puts "ok !"
end
