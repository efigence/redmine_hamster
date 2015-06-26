require File.expand_path('../../test_helper', __FILE__)
require 'pry'
class HamstersControllerTest < Redmine::IntegrationTest
  fixtures :users, :issues, :projects, :issue_statuses, :members,
           :roles, :member_roles, :enabled_modules,
           :time_entries, :trackers, :enumerations, :issue_categories,
           :projects_trackers, :journals, :journal_details
  def setup
    Hamster.destroy_all
    HamsterIssue.destroy_all
  end

  def test_start_issue_should_create_new_hamster_issue
    log_user('jsmith', 'jsmith')
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 4
      assert_response 302
    end
  end

  def test_start_and_stop_issue
    log_user('jsmith', 'jsmith')
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 4
      assert_response 302
    end
    hi = HamsterIssue.where(user_id: User.current.id).first
    hi.start_at = hi.start_at - 2.hours
    hi.save
    assert_difference 'Hamster.count', +1 do
      assert_difference 'HamsterIssue.count', -1 do
        post hamsters_stop_path, hamster_issue_id: hi.id
        h = Hamster.where(user_id: User.current.id, issue_id: 4).first
        assert_equal h.spend_time, 2.0, 'Spent time should be 2 hours'
      end
    end
  end

  def test_start_stop_raport_time
    log_user('dlopper', 'foo')
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 3
      assert_response 302
    end
    hi = HamsterIssue.where(user_id: User.current.id).first
    hi.start_at = hi.start_at - 3.hours
    hi.save
    assert_difference 'Hamster.count', +1 do
      assert_difference 'HamsterIssue.count', -1 do
        post hamsters_stop_path, hamster_issue_id: hi.id
        h = Hamster.where(user_id: User.current.id, issue_id: 3).first
        assert_equal h.spend_time, 3.0, 'Spent time should be 3 hours'
      end
    end
    date = hi.start_at.to_date.to_s
    hamster = Hamster.where(user_id: User.current.id, issue_id: 3).first
    assert_difference 'TimeEntry.count', +1 do
      post raport_time_path, time_entry: {issue_id: 3 , spent_on: date, hours: hamster.spend_time, hamster_id: hamster.id, activity_id: 10 }
      te = TimeEntry.where(user_id: User.current.id, issue_id: 3).last
      assert_equal te.hours, 3.0, 'Raported time should be 3.0'
    end
  end

end
