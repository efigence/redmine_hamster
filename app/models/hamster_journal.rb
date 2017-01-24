class HamsterJournal < ActiveRecord::Base
  unloadable
  attr_accessible :user_id, :issue_id, :from, :to, :summary
  belongs_to :hamster
  belongs_to :user
  belongs_to :issue

  after_destroy :substract_hours_from_hamster

  private

  def substract_hours_from_hamster
    h = self.hamster
    h.spend_time = h.spend_time - self.summary.to_f
    if h.spend_time < 0
      if h.hamster_journals.any?
        h.spend_time = h.hamster_journals.map(&:summary).map(&:to_f).try(:sum) || 0.0
      end
    end
    h.save
  end

end
