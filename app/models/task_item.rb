class TaskItem < ApplicationRecord
  belongs_to :task
  belongs_to :list

  def update_score(step_count)
    if step_count < self.task.max_steps
      self.score = step_count * self.task.score_per_step
      self.is_completed = false

    else
      self.score = (self.task.max_steps * self.task.score_per_step) + (step_count - self.task.max_steps)
      self.is_completed = true

    end

    self.step_count = step_count
    self.save
  end
end
