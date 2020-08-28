class Task < ApplicationRecord
  belongs_to :game
  has_many :task_items
  has_many :lists, through: :task_items

  def self.set_bonus_scores(list)
    list.tasks.each do |task|
      case task.name
      when "Fruits & légumes" then list.task_items.where(task: task).first.update_score(list.get_good_and_limit_foodgroup_items(FoodGroup.find(1)).size)
      # when "Fruits & légumes de saison" then (List.where(list_type: "curated").last.categories.map{ |c| c.subtree }.flatten.uniq.pluck(:id) & list.get_foodgroup_items(FoodGroup.first).pluck(:category_id).uniq).size
      when 'Féculents' then list.task_items.where(task: task).first.update_score(list.get_good_and_limit_foodgroup_items(FoodGroup.find(2)).size)
      when "Légumes secs" then list.task_items.where(task: task).first.update_score(list.get_good_and_limit_foodgroup_items(FoodGroup.find(22)).size)
      when "Fruits à coque & graines" then list.task_items.where(task: task).first.update_score(list.get_good_and_limit_foodgroup_items(FoodGroup.find(15)).size)
      when "Produits laitiers" then list.task_items.where(task: task).first.update_score(list.get_good_and_limit_foodgroup_items(FoodGroup.find(5)).size)
      when "Poissons" then list.task_items.where(task: task).first.update_score(list.get_good_and_limit_foodgroup_items(FoodGroup.find(25)).size)
      end
    end
  end

end
