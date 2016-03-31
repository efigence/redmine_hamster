require File.expand_path('../../test_helper', __FILE__)

class Api::HamsterJournalsControllerTest < Redmine::ApiTest::Base
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

    @user = User.find_by(login: 'jsmith')
    @hamster = Hamster.create(user_id: @user.id,
                              issue_id: 2,
                              start_at: Time.now - 2.hours,
                              end_at: Time.now,
                              spend_time: 2.0)
    @journal = @hamster.hamster_journals.create(user_id: @user.id,
                                                from: (Time.now - 2.hours).to_s,
                                                to: Time.now.to_s,
                                                summary: '2.0',
                                                issue_id: @hamster.issue_id)
  end

  test 'user should be correct' do
    get api_hamster_journals_hamster_journals_path, { hamster_id: @hamster.id }, { 'X-Redmine-API-Key' => @user.api_key }
    assert_equal @user, User.current
  end

  test 'return 401 when without api key' do
    get api_hamster_journals_hamster_journals_path, { hamster_id: @hamster.id }
    assert_response 401
  end

  test 'return 401 when wrong api key' do
    get api_hamster_journals_hamster_journals_path, { hamster_id: @hamster.id }, { 'X-Redmine-API-Key' => '123456789' }
    assert_response 401
  end

  test '#hamster_journals should return hamsters journals' do
    get api_hamster_journals_hamster_journals_path, { hamster_id: @hamster.id }, { 'X-Redmine-API-Key' => @user.api_key }
    response_json = JSON.parse(response.body)[0]
    assert_response 200
    assert_equal @journal.user_id, response_json['user_id']
    assert_equal @journal.issue_id, response_json['issue_id']
    assert_equal @journal.hamster_id, response_json['hamster_id']
    assert_equal @journal.summary, response_json['summary']
  end

  test '#update should update and return hamster_journal' do
    time_to = (Time.now + 2.hours).to_s
    time_from = (Time.now - 3.hours).to_s
    assert_difference 'Hamster.find(@hamster.id).spend_time', 3.0 do
      patch api_hamster_journals_update_path, { id: @journal.id, to: time_to, from: time_from }, { 'X-Redmine-API-Key' => @user.api_key }
      response_json = JSON.parse(response.body)
      assert_response 200
      assert_equal time_to, response_json['to']
      assert_equal time_from, response_json['from']
      assert_equal 5.0.to_s, response_json['summary']
    end
  end

  test '#destroy should destroy hamster_journal' do
    assert_difference 'HamsterJournal.count', -1 do
      delete api_hamster_journals_delete_path, { id: @journal.id }, { 'X-Redmine-API-Key' => @user.api_key }
      response_json = JSON.parse(response.body)
      assert_response 200
      assert_equal 200, response_json['status']
    end
  end

end
