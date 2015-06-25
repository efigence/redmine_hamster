class HamsterIssue < ActiveRecord::Base
  unloadable
  attr_accessible :user_id, :issue_id, :start_at

  belongs_to :issue

  scope :my, -> { where(user_id: User.current.id) }

  def stop
    end_time = DateTime.now
    diff = TimeDifference.between(self.start_at, end_time).in_hours
    h = Hamster.create_or_update(end_time, diff, self.issue_id, self.user_id)
    self.destroy if h
  end

  def self.start issue_id
    HamsterIssue.create(user_id: User.current.id, issue_id: issue_id, start_at: DateTime.now)
  end

end
