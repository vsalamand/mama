desc "send day1 user a customer feedback email from founder"
task send_day1_email: :environment do
  puts "Sending email from founder to day 1 users..."
  Day1feedbackJob.perform_now
  puts "ok !"
end
