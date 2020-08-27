class Task < ApplicationRecord
  belongs_to :game
  has_many :task_items
  has_many :lists, through: :task_items

  def set_bonus_scores(list)
    case self.name
    when "5 fruits & légumes" then list.task_items.where(task: self).first.update_score(list.get_good_and_limit_foodgroup_items(FoodGroup.find(1)).size)
    when 'Féculents' then list.task_items.where(task: self).first.update_score(list.get_good_and_limit_foodgroup_items(FoodGroup.find(2)).size)
  # "Bonus fruits & légumes de saison" = (List.where(list_type: "curated").last.categories.map{ |c| c.subtree }.flatten.uniq.pluck(:id) & self.get_foodgroup_items(FoodGroup.first).pluck(:category_id).uniq).size
    end
  end

end
