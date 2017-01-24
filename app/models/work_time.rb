class WorkTime < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  after_save :invalidate_cache
  DEFAULT = 8.0 #hours

  belongs_to :user

  attr_protected :user_id
  safe_attributes :user_id, :start_at, :end_at, :multi_start, :start_status_to, :stop_status_to, :days_ago, :show_current_issue

  validates :user_id, presence: true
  validates :end_at, presence: true, if: :start_at
  validates :start_at, presence: true, if: :end_at

  private

  def invalidate_cache
    Rails.cache.delete("active_issue_for_#{User.current.id}")
  end
end
