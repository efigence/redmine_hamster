class WorkTime < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable

  DEFAULT = 8.0 #hours

  belongs_to :user

  attr_protected :user_id
  safe_attributes :user_id, :start_at, :end_at, :multi_start, :start_status_to, :stop_status_to, :days_ago

  validates :user_id, presence: true
  validates :end_at, presence: true, if: :start_at
  validates :start_at, presence: true, if: :end_at
end
