class WeeklyMenuJob < ApplicationJob
  queue_as :default

  def perform
    schedule = Date.today.strftime("%W, %Y")
    # update users weekly recommendations menu
    Diet.all.each do |diet|
      recommendations = Recommendation.where(diet_id: diet.id, schedule: schedule)
      content = []
      recommendations.each { |reco| content << reco.recipes }
      content = content.flatten.shuffle
      User.where(diet: diet).each { |user| Recommendation.update_user_weekly_menu(user, schedule, content) }
    end
  end
end
