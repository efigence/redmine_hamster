class Hamster < ActiveRecord::Base
  unloadable
  attr_accessible :user_id, :issue_id, :start_at, :status, :end_at, :spend_time

  scope :my, -> { where(user_id: User.current.id) }

  def self.create_or_update(start_date, end_time, spend_time, issue_id, user_id)
    hamster = Hamster.my.where(start_at: start_date.beginning_of_day..start_date.end_of_day, issue_id: issue_id) # created today
    if hamster.any?
      hamster = hamster.first
      time = (hamster.spend_time + spend_time).round(2)
      hamster.update_attributes(end_at: end_time, spend_time: time)
    else
      Hamster.create(user_id: user_id, issue_id: issue_id, start_at: start_date, end_at: end_time, spend_time: spend_time)
    end
  end

end
