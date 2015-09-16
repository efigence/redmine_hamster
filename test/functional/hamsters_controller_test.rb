require File.expand_path('../../test_helper', __FILE__)

class HamstersControllerTest < Redmine::IntegrationTest
  self.fixture_path = File.join(File.dirname(__FILE__), '../fixtures')
  fixtures :users,
           :issues,
           :projects,
           :issue_statuses,
           :members,
           :settings,
           :roles,
           :enabled_modules,
           :time_entries,
           :trackers,
           :email_addresses,
           :groups_users,
           :member_roles

  def setup
    Hamster.destroy_all
    HamsterIssue.destroy_all
    WorkTime.destroy_all
    WorkflowTransition.destroy_all
    WorkflowTransition.create!(:role_id => 2, :tracker_id => 1, :old_status_id => 1, :new_status_id => 2, :author => false, :assignee => false)
    WorkflowTransition.create!(:role_id => 2, :tracker_id => 1, :old_status_id => 1, :new_status_id => 3, :author => true, :assignee => false)
    WorkflowTransition.create!(:role_id => 2, :tracker_id => 1, :old_status_id => 1, :new_status_id => 4, :author => false, :assignee => true)
    WorkflowTransition.create!(:role_id => 2, :tracker_id => 1, :old_status_id => 1, :new_status_id => 5, :author => true, :assignee => true)
    WorkflowTransition.create!(:role_id => 2, :tracker_id => 1, :old_status_id => 2, :new_status_id => 3, :author => true, :assignee => true)
  end

  def test_start_issue_should_create_new_hamster_issue
    log_user('jsmith', 'jsmith')
    allow_user(User.current)#as admin
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 4
      assert_response 302
    end
  end

  def test_start_and_stop_issue
    log_user('jsmith', 'jsmith')
    allow_user(User.current) #as admin
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
    allow_user(User.current) # as admin
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 3
      assert_response 302
    end
    hi = User.current.hamster_issues.first
    hi.start_at = hi.start_at - 3.hours
    hi.save
    assert_difference 'Hamster.count', +1 do
      assert_difference 'HamsterIssue.count', -1 do
        post hamsters_stop_path, hamster_issue_id: hi.id
        h = User.current.hamsters.where(issue_id: 3).first
        assert_equal h.spend_time, 3.0, 'Spent time should be 3 hours'
      end
    end
    date = hi.start_at.to_date.to_s
    hamster = User.current.hamsters.where(issue_id: 3).first
    assert_difference 'TimeEntry.count', +1 do
      post raport_time_path, time_entry: {issue_id: 3 , spent_on: date, hours: hamster.spend_time, hamster_id: hamster.id, activity_id: 10 }
      te = TimeEntry.where(user_id: User.current.id, issue_id: 3).last
      assert_equal te.hours, 3.0, 'Raported time should be 3.0'
    end
  end

  def test_divide_hamster_issue_by_days_on_stop
    log_user('dlopper', 'foo')
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
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 3
      assert_response 302
    end
    hi = HamsterIssue.find_by(user_id: User.current.id, issue_id: 3)
    old_updated_on = Issue.find(3).updated_on
    Timecop.freeze(DateTime.now + 2) do
      assert_difference 'Hamster.count', +3 do
        post hamsters_stop_path, hamster_issue_id: hi.id
        assert_equal User.current.working_hours, Hamster.second.spend_time, "Spend time should by #{User.current.working_hours}"
        assert_equal true, Issue.find(3).updated_on > old_updated_on, 'Should be greater'
      end
    end
  end

  def test_start_after_user_finish_time_work_and_stop_on_next_day_should_set_1_hour
    # User finish work at 17:00(by default)
    log_user('dlopper', 'foo')
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
    worktime_build({start_at: '09:00', end_at: '17:00', multi_start: false})
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
    worktime_build({start_at: '09:00', end_at: '17:00', multi_start: true})
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
    worktime_build({start_at: '09:00', end_at: '17:00', start_status_to: 2, stop_status_to: 3})
    assert_difference ['HamsterIssue.count', 'Journal.count'], +1 do
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
    # this user is not an admin and has no groups
    log_user('someone', 'foo')
    assert_equal 0, User.current.groups.count, "User should not have any groups"
    get hamsters_index_path
    assert_response 403
  end

  def test_permitted_group
    # dlopper belongs to allowed group -> 10
    log_user('dlopper', 'foo')
    get hamsters_index_path
    assert_response 200
  end

  def test_should_not_change_status_for_issue_assigned_to_other_user
    # issue 3 -> status_id : 1
    log_user('jsmith', 'jsmith')
    allow_user(User.current)#as admin
    worktime_build({start_status_to: 2, stop_status_to: 4})
    assert_difference 'HamsterIssue.count', +1 do
      assert_not_equal User.current.id, Issue.find(3).assigned_to_id, 'Id should be different'
      post hamsters_start_path, issue_id: 3
      assert_response 302
      assert_equal 1, HamsterIssue.last.issue.status_id, 'Status should not be changed'
    end
    post signout_path
    log_user('dlopper', 'foo')
    worktime_build({start_status_to: 2, stop_status_to: 3})
    assert_difference 'HamsterIssue.count', +1 do
      assert_equal User.current.id, Issue.find(3).assigned_to_id, 'Issue should assigne to this user!'
      post hamsters_start_path, issue_id: 3
      assert_response 302
      assert_equal 2, HamsterIssue.last.issue.status_id, 'Status should be changed'
    end
    hi = HamsterIssue.my.first
    post hamsters_stop_path, hamster_issue_id: hi.id
    assert_equal 3, Issue.find(3).status_id, 'Status should be changed'
  end

  def test_should_not_destroy_hamster_issues_other_user_in_the_same_issue
    log_user('jsmith', 'jsmith')
    allow_user(User.current)#as admin
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 4
      assert_response 302
    end
    post signout_path
    log_user('dlopper', 'foo')
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 4
      assert_response 302
    end
    assert_equal 2, HamsterIssue.where(issue_id: 4).count, 'Wrong issue count!'
    assert_difference 'HamsterIssue.count', -1 do
      hi = HamsterIssue.my.first
      post hamsters_stop_path, hamster_issue_id: hi.id
      assert_response 302
    end
    assert_equal 1, HamsterIssue.where(issue_id: 4).count, 'Wrong issue count!'
  end

  def test_should_return_default_data_when_is_not_set
    log_user('jsmith', 'jsmith')
    assert_equal nil, User.current.work_time, 'There is no data - should be nil'
    assert_equal '09:00', User.current.start_at, 'Schould equal default start_at'
    assert_equal '17:00', User.current.end_at, 'Schould equal default end_at'
    assert_equal 7, User.current.raported_days_count, 'Schould equal 7'
    assert_equal false, User.current.multi_start_enabled?, 'Schould not be enable by default'
    assert_equal 8.0, User.current.working_hours, 'Should equal default working hours'
  end

  def test_should_return_user_data_from_work_time
    log_user('jsmith', 'jsmith')
    worktime_build({start_at: '10:00', end_at: '18:00', multi_start: true, days_ago: 2})
    assert_not_equal nil, User.current.work_time, 'Should not be nil'
    assert_equal '10:00', User.current.start_at, 'Schould equal user start_at'
    assert_equal '18:00', User.current.end_at, 'Schould equal user end_at'
    assert_equal 2, User.current.raported_days_count, 'Schould equal 2'
    assert_equal true, User.current.multi_start_enabled?, 'Should be enabled by user'
    User.current.work_time.update_attributes(:end_at => '18:30')
    assert_equal 8.5, User.current.working_hours, 'Should equal user working hours'
  end

  def test_should_not_change_issue_status_if_is_not_allowed_to
    log_user('dlopper', 'foo')
    worktime_build({start_status_to: 6, stop_status_to: 1})
    Issue.first.update_attributes(assigned_to_id: User.current.id)
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 1
      assert_response 302
    end
    assert_equal 1, Issue.find(1).status_id, 'Status should not be changed'
    User.current.hamster_issues.destroy_all
    User.current.work_time.destroy
    worktime_build({start_status_to: 2, stop_status_to: 1})
    assert_difference 'HamsterIssue.count', +1 do
      post hamsters_start_path, issue_id: 1
      assert_response 302
    end
    assert_equal 2, Issue.find(1).status_id, 'Status should be changed'
  end

  def test_destroy_all_user_hamsters
    log_user('dlopper', 'foo')
    ids = Issue.my_open.collect(&:id)
    assert_difference 'Hamster.count', +2 do
      post hamsters_start_path, issue_id: ids.first
      post hamsters_start_path, issue_id: ids.last
      post hamsters_stop_path, hamster_issue_id: HamsterIssue.my.first.id
    end
    assert_difference 'Hamster.count', -2 do
      post remove_hamsters_path
    end
    assert_equal 0, Hamster.my.count, 'Should be empty array!'
  end

  def test_should_remove_only_current_user_hamsters
    log_user('jsmith', 'jsmith')
    allow_user(User.current)
    assert_difference 'Hamster.count', +1 do
      post hamsters_start_path, issue_id: Issue.my_open.last.id
      post hamsters_stop_path, hamster_issue_id: HamsterIssue.my.first.id
    end
    post signout_path
    log_user('dlopper', 'foo')
    assert_difference 'Hamster.count', +1 do
      post hamsters_start_path, issue_id: Issue.my_open.last.id
      post hamsters_stop_path, hamster_issue_id: HamsterIssue.my.first.id
    end
    assert_difference 'Hamster.count', -1 do
      post remove_hamsters_path
    end
    assert_equal 1, Hamster.count, 'Wrong hamsters count'
  end

  private

  def worktime_build params
    WorkTime.destroy_all
    wt = User.current.build_work_time(params)
    wt.save
  end

  def allow_user user
    user.admin = true
    user.save
  end
end
