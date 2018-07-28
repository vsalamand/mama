namespace :recommendation do
  desc "Create new recommended menus for the coming week, every monday"
  task update_all: :environment do
    if Date.today.monday?
      puts "updating mama..."
      MamaJob.perform_now
      puts "done !"
    else
      puts "Today is not Monday. Recommendations are updated every Monday"
    end
  end

  desc "update mama now"
  task update_all_now: :environment do
    puts "updating mama..."
    MamaJob.perform_now
    puts "done !"
  end

  desc "update food lists now"
  task update_foodlists_now: :environment do
    puts "updating foodlists..."
    FoodListJob.perform_now
    puts "done !"
  end

  desc "update recipe lists now"
  task update_recipelists_now: :environment do
    puts "updating recipelists..."
    RecipeListJob.perform_now
    puts "done !"
  end

  desc "update recommendations now"
  task update_recommendations_now: :environment do
    puts "updating recommendations..."
    RecommendationJob.perform_now
    puts "done !"
  end

  desc "update weekly menus now"
  task update_weeklymenus_now: :environment do
    puts "updating weekly menus..."
    WeeklyMenuJob.perform_now
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

  desc "upload recipe cards to cloudinary now"
  task upload_cards_now: :environment do
    puts "uploading recipe cards..."
    CardsJob.perform_now
    puts "done !"
  end

end
