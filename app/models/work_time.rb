class WorkTime < ActiveRecord::Base
  unloadable
  attr_accessible :user_id, :start_at, :end_at, :multi_start, :start_status_to, :stop_status_to
  belongs_to :user

  DEFAULT = 8.0 #hours

  validates :user_id, :start_at, :end_at, presence: true
  validates :start_status_to, presence: true, if: :stop_status_to
  validates :stop_status_to, presence: true, if: :start_status_to

end
