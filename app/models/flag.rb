class Flag < ApplicationRecord
  belongs_to :user

  def send_pmf_survey(user)
    Flag.create(name: "pmf_survey", user_id: user.id, created_at: DateTime.now)
  end

  def is_inactive(user)
    Flag.create(name: "inactive", user_id: user.id, created_at: DateTime.now)
  end
end
