require File.expand_path('../../test_helper', __FILE__)

class HamstersControllerTest < Redmine::IntegrationTest
  fixtures :users, :issues, :projects, :issue_statuses, :members,
           :roles, :member_roles, :enabled_modules,
           :time_entries, :trackers, :enumerations, :issue_categories,
           :projects_trackers, :journals, :journal_details, :groups_users,
           :email_addresses

  def setup
    Hamster.destroy_all
    HamsterIssue.destroy_all
    WorkTime.destroy_all
    Group.destroy_all
  end

  def test_start_issue_should_create_new_hamster_issue
    log_user('jsmith', 'jsmith')
    allow_user(User.current)
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 4
      assert_response 302
    end
  end

  def test_start_and_stop_issue
    log_user('jsmith', 'jsmith')
    allow_user(User.current)
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
    allow_user(User.current)
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

  def test_divide_hamster_issue_by_days_on_stop
    log_user('dlopper', 'foo')
    allow_user(User.current)
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 3
      assert_response 302
    end
    hi = HamsterIssue.find_by(user_id: User.current.id, issue_id: 3).update_attributes(start_at: 2.business_days.ago)
    hi = HamsterIssue.find_by(user_id: User.current.id, issue_id: 3)
    assert_difference 'Hamster.count', +3 do
      post hamsters_stop_path, hamster_issue_id: hi.id
    end
  end

  def test_middle_raported_day_shoud_equal_user_working_hours
    # quaue -> today, yesterday, etc..
    log_user('dlopper', 'foo')
    allow_user(User.current)
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 3
      assert_response 302
    end
    hi = HamsterIssue.find_by(user_id: User.current.id, issue_id: 3).update_attributes(start_at: 2.business_days.ago)
    hi = HamsterIssue.find_by(user_id: User.current.id, issue_id: 3)
    assert_difference 'Hamster.count', +3 do
      post hamsters_stop_path, hamster_issue_id: hi.id
      assert_equal User.current.working_hours, Hamster.second.spend_time, "Spend time should by #{User.current.working_hours}"
    end
  end

  def test_start_after_user_finish_time_work_and_stop_on_next_day_should_set_1_hour
    # User finish work at 17:00(by default)
    log_user('dlopper', 'foo')
    allow_user(User.current)
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 3
      assert_response 302
    end
    # start issue before 6 p.m.
    hi = HamsterIssue.find_by(user_id: User.current.id, issue_id: 3).update_attributes(start_at: 1.business_days.ago.end_of_day-6.hours)
    hi = HamsterIssue.find_by(user_id: User.current.id, issue_id: 3)
    assert_difference 'Hamster.count', +2 do
      post hamsters_stop_path, hamster_issue_id: hi.id
      assert_equal 1.0, Hamster.last.spend_time, 'Spend time should equal 1.0'
      diff = TimeDifference.between(User.current.start_at, Time.now).in_hours.floor
      assert_equal diff, Hamster.first.spend_time.floor, 'Spend time should equal 1.0'
    end
  end

  def test_disabled_multi_start_issues
    log_user('dlopper', 'foo')
    allow_user(User.current)
    WorkTime.create(user_id: User.current.id, start_at: '09:00', end_at: '17:00', multi_start: false)
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 3
      assert_response 302
    end
    assert_difference 'Hamster.count', +1 do
      assert_no_difference 'HamsterIssue.count' do
        post hamsters_start_path, issue_id: 2
        assert_response 302
      end
    end
  end

  def test_enabled_multi_start_issues
    log_user('dlopper', 'foo')
    allow_user(User.current)
    WorkTime.create(user_id: User.current.id, start_at: '09:00', end_at: '17:00', multi_start: true)
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 3
      assert_response 302
    end
    assert_no_difference 'Hamster.count' do
      assert_difference 'HamsterIssue.count', +1 do
        post hamsters_start_path, issue_id: 2
        assert_response 302
      end
    end
  end

  def test_change_status_after_start_stop
    log_user('dlopper', 'foo')
    allow_user(User.current)
    WorkTime.create(user_id: User.current.id, start_at: '09:00', end_at: '17:00', start_status_to: 2, stop_status_to: 3)
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 3
      assert_response 302
      assert_equal 2, Issue.find(3).status_id, "Wrong status id after start"
    end
    assert_difference 'HamsterIssue.count', -1 do
      post hamsters_stop_path, hamster_issue_id: HamsterIssue.first.id
      assert_response 302
      assert_equal 3, Issue.find(3).status_id, "Wrong status id after stop"
    end
  end

  def test_permissions
    log_user('dlopper', 'foo')
    get hamsters_index_path
    assert_response 403
  end

  private

  def allow_user user
    user.admin = true
    user.save
  end
end
