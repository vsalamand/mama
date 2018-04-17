namespace :recommendation do
  desc "Create new recommended menus for the coming week, every monday"
  task update_all: :environment do
    puts "updating recommendations..."
    RecommendationJob.set(wait_until: Date.today.next_week(:monday).midnight).perform_later
    puts "done !"
  end

end
