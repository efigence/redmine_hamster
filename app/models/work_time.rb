class WorkTime < ActiveRecord::Base
  unloadable
  attr_accessible :user_id, :start_at, :end_at
  belongs_to :user

  DEFAULT = 8.0 #hours

  validates :user_id, :start_at, :end_at, presence: true
end
