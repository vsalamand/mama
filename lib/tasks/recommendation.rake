namespace :recommendation do
  desc "Create new recommended menus for the coming week, every monday"
  task update_all: :environment do
    puts "updating recommendations..."
    RecommendationJob.set(wait_until: Date.today.next_week(:monday).midnight).perform_later
    puts "done !"
  end

  desc "update recommendations now"
  task update_all_now: :environment do
    puts "updating recommendations..."
    RecommendationJob.perform_now
    puts "done !"
  end

end
