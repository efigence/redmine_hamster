class Hamster < ActiveRecord::Base
  unloadable
  attr_accessible :user_id, :issue_id, :start_at, :status, :end_at, :spend_time

  scope :my, -> { where(user_id: User.current.id) }

  def self.create_or_update(end_time, spend_time, issue_id, user_id)
    hamster = Hamster.my.where("created_at >= ? AND issue_id = ?", Time.zone.now.beginning_of_day, issue_id) # created today
    if hamster.any?
      hamster = hamster.first
      time = (hamster.spend_time + spend_time).round(2)
      hamster.update_attributes(end_time: end_time, spend_time: time)
    else
      Hamster.create(user_id: user_id, issue_id: issue_id, end_time: end_time, spend_time: spend_time)
    end
  end

end
