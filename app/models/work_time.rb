class WorkTime < ActiveRecord::Base
  unloadable
  attr_accessible :user_id, :start_at, :end_at, :multi_start, :start_status_to, :stop_status_to
  belongs_to :user

  DEFAULT = 8.0 #hours

  validates :user_id, presence: true
  validates :end_at, presence: true, if: :start_at
  validates :start_at, presence: true, if: :end_at
  validates :start_status_to, presence: true, if: :stop_status_to
  validates :stop_status_to, presence: true, if: :start_status_to

end
