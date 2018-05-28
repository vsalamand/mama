namespace :recommendation do
  desc "Create new recommended menus for the coming week, every monday"
  task update_all: :environment do
    if Date.today.monday?
      puts "updating recommendations..."
      RecommendationJob.perform_now
      puts "done !"
    else
      puts "Today is not Monday. Recommendations are updated every Monday"
    end
  end

  desc "update recommendations now"
  task update_all_now: :environment do
    puts "updating recommendations..."
    RecommendationJob.perform_now
    puts "done !"
  end

  desc "update food checklists now"
  task update_checklists_now: :environment do
    puts "updating checklists..."
    ChecklistJob.perform_now
    puts "done !"
  end

  desc "rate all recipes now"
  task rate_recipes_now: :environment do
    puts "rating recipes..."
    RecipeJob.perform_now
    puts "done !"
  end

end
