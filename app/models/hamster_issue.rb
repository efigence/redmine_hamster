class HamsterIssue < ActiveRecord::Base
  unloadable
  attr_accessible :user_id, :issue_id, :start_at

  belongs_to :issue
  belongs_to :user

  scope :my, -> { where(user_id: User.current.id) }
  after_commit :touch_issue

  def stop
    end_time = DateTime.now
    start_at = Time.zone.parse(self.start_at.to_s).localtime
    diff = TimeDifference.between(start_at, end_time).in_hours
    if same_day?(start_at, end_time)
      h = Hamster.create_or_update(start_at, end_time, diff, self.issue_id, self.user_id)
      self.issue.change_issue_on_stop
      self.destroy if h
    else
      days = Date.parse(start_at.to_s).business_days_until(Date.today) # bussines days between dates
      (0..days).to_a.each do |i|
        date = i.business_days.ago
        spent_time = set_spent_time(i, days, start_at)
        h = Hamster.create_or_update(date.to_datetime, end_time, spent_time, self.issue_id, self.user_id)
      end
      self.issue.change_issue_on_stop
      self.destroy if h
    end
  end

  def self.start issue_id
    HamsterIssue.create(user_id: User.current.id, issue_id: issue_id, start_at: DateTime.now)
  end

  private

  def touch_issue
    retry_count ||= 0
    issue.reload
    issue.touch
  rescue ActiveRecord::StaleObjectError => ex
    retry_count += 1
    raise ex if retry_count > 3
    sleep retry_count * 2
    retry
  end

  def set_spent_time i, days, start_at
    if i == 0 #day of end
        spent_time = TimeDifference.between(User.current.start_at, Time.now.strftime('%H:%M')).in_hours
    elsif i == days # day of start
      if User.current.end_at <= start_at.strftime('%H:%M')
        spent_time = 1.0
      else
        spent_time = TimeDifference.between(start_at.strftime('%H:%M'), User.current.end_at).in_hours
      end
    else # day between
      spent_time = User.current.working_hours
    end
  end

  def get_hamster_hours_for_date date
    # check for hamstered hours in this day
    Hamster.where(start_at: date.beginning_of_day..date.end_of_day, user_id: User.current.id).sum('spend_time')
  end

  def same_day? start_date, end_date
    start_date.to_date == end_date.to_date if start_date && end_date
  end
end
