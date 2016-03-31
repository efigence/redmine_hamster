require File.expand_path('../../test_helper', __FILE__)

class Api::HamstersControllerTest < Redmine::ApiTest::Base
  self.fixture_path = File.join(File.dirname(__FILE__), '../fixtures')
  fixtures :all

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

  test 'user should be correct' do
    user = User.find_by(login: 'jsmith')
    get api_hamster_index_path, {}, { 'X-Redmine-API-Key' => user.api_key }
    assert_equal user, User.current
  end

  test 'return 401 when without api key' do
    get api_hamster_index_path
    assert_response 401
  end

  test 'return 401 when wrong api key' do
    get api_hamster_index_path, {}, { 'X-Redmine-API-Key' => '123456789' }
    assert_response 401
  end

  test '#index should return users hamsters' do
    user = User.find_by(login: 'jsmith')
    hamster = Hamster.create(user_id: user.id, issue_id: 2, start_at: Time.now - 2, end_at: Time.now, spend_time: 0.1)
    get api_hamster_index_path, {}, { 'X-Redmine-API-Key' => user.api_key }
    response_json = JSON.parse(response.body)[0]
    assert_response 200
    assert_equal user.id, response_json['user_id']
    assert_equal 2, response_json['issue_id']
    assert_equal 0.1, response_json['spend_time']
  end

  test '#my_issues should return proper issues' do
    user = User.find_by(login: 'jsmith')
    get api_hamster_my_issues_path, {}, { 'X-Redmine-API-Key' => user.api_key }
    response_json = JSON.parse(response.body)
    assert_response 200
    response_json.each do |issue|
      assert_equal user.id, issue['assigned_to_id']
    end
  end

  test '#my_active_hamsters should return proper hamster_issues' do
    user = User.find_by(login: 'jsmith')
    HamsterIssue.create(user_id: user.id, issue_id: 2, start_at: Time.now - 2000)
    get api_hamster_my_active_hamsters_path, {}, { 'X-Redmine-API-Key' => user.api_key }
    response_json = JSON.parse(response.body)[0]
    assert_response 200
    assert_equal user.id, response_json['user_id']
    assert_equal 2, response_json['issue_id']
  end

  test '#my_ready_to_raport_hamsters should return proper hamsters' do
    user = User.find_by(login: 'jsmith')
    hamster = Hamster.create(user_id: user.id, issue_id: 2, start_at: Time.now - 2, end_at: Time.now, spend_time: 0.1)
    get api_hamster_my_ready_to_raport_hamsters_path, {}, { 'X-Redmine-API-Key' => user.api_key }
    response_json = JSON.parse(response.body)[Time.now.strftime('%F')][0]
    assert_response 200
    assert_equal user.id, response_json['user_id']
    assert_equal 2, response_json['issue_id']
    assert_equal 0.1, response_json['spend_time']
  end

  test '#start should return proper hamster_issue' do
    user = User.find_by(login: 'jsmith')
    post api_hamster_start_path, { issue_id: 2 }, { 'X-Redmine-API-Key' => user.api_key }
    response_json = JSON.parse(response.body)
    assert_response 200
    assert_equal HamsterIssue.last.user_id, response_json['user_id']
    assert_equal HamsterIssue.last.issue_id, response_json['issue_id']
  end

  test '#stop should return proper hamster' do
    user = User.find_by(login: 'jsmith')
    hamster_issue = HamsterIssue.create(user_id: user.id, issue_id: 2, start_at: Time.now - 2000)
    post api_hamster_stop_path, { hamster_issue_id: hamster_issue.id }, { 'X-Redmine-API-Key' => user.api_key }
    response_json = JSON.parse(response.body)
    assert_response 200
    assert_equal Hamster.last.user_id, response_json['user_id']
    assert_equal Hamster.last.issue_id, response_json['issue_id']
  end

  test '#update should return proper hamster' do
    user = User.find_by(login: 'jsmith')
    hamster = Hamster.create(user_id: user.id, issue_id: 2, start_at: Time.now - 2, end_at: Time.now, spend_time: 0.1)
    patch api_hamster_update_path, { id: hamster.id, hamster: { spend_time: 1.2 } }, { 'X-Redmine-API-Key' => user.api_key }
    response_json = JSON.parse(response.body)
    assert_response 200
    assert_equal 1.2, hamster.reload.spend_time
    assert_equal 1.2, response_json['spend_time']
  end

  test '#destroy should delete proper hamster' do
    user = User.find_by(login: 'jsmith')
    hamster = Hamster.create(user_id: user.id, issue_id: 2, start_at: Time.now - 2, end_at: Time.now, spend_time: 0.1)
    delete api_hamster_delete_path, { id: hamster.id }, { 'X-Redmine-API-Key' => user.api_key }
    assert_response 200
    assert Hamster.my.empty?
  end

  test '#raport_time should delete proper hamster' do
    user = User.find_by(login: 'jsmith')
    hamster = Hamster.create(user_id: user.id, issue_id: 2, start_at: Time.now - 1.hour, end_at: Time.now, spend_time: 1.0)
    post api_hamster_raport_time_path, { time_entry: { issue_id: 2, spent_on: Time.now.strftime('%F'), hamster_id: hamster.id, hours: hamster.spend_time } }, { 'X-Redmine-API-Key' => user.api_key }
    response_json = JSON.parse(response.body)
    assert_response 200
    assert_equal 1.0, TimeEntry.last.hours, "Wrong hours value!"
    assert Hamster.all.empty?
    assert_equal Issue.find(2).project_id, response_json['project_id']
    assert_equal 2, response_json['issue_id']
    assert_equal user.id, response_json['user_id']
  end

end
