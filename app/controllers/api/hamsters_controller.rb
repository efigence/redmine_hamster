# request.headers['X-Redmine-API-Key']

class Api::HamstersController < ApplicationController
  unloadable

  accept_api_auth :index, :my_issues, :mru, :my_active_hamsters, :my_ready_to_raport_hamsters,
                  :start, :stop, :update, :destroy, :raport_time

  before_filter :set_current_user

  before_action :find_issue,   only: [:start]
  before_action :find_hamster, only: [:update, :destroy]
  before_action :find_hamster_issue, only: [:stop]
  before_action :prepare_data, only: [:raport_time]

  skip_before_filter :check_if_login_required
  skip_before_filter :verify_authenticity_token

  def index
    render json: Hamster.my
  end

  def my_issues
    render json: RedmineHamster::LoadData.my_issues
  end

  def mru
    render json: RedmineHamster::LoadData.mru
  end

  def my_active_hamsters
    render json: RedmineHamster::LoadData.my_active_hamsters
  end

  def my_ready_to_raport_hamsters
    render json: RedmineHamster::LoadData.my_ready_to_raport_hamsters
  end

  def start
    stop_others unless User.current.multi_start_enabled?
    @hamster_issue = HamsterIssue.start(@issue.id)
    @issue.change_issue_status(:start_status_to)
    render json: @hamster_issue
  end

  def stop
    @hamster_issue.stop if @hamster_issue
    render json: Hamster.my.last
  end

  def update
    @hamster.update_attributes(spend_time: params[:hamster][:spend_time])
    render json: @hamster
  end

  def destroy
    render json: { status: 200 } if @hamster.destroy
  end

  def raport_time
    time_entry = TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => @date, hours: @hours)
    time_entry.safe_attributes = params[:time_entry]

    if time_entry.project && !User.current.allowed_to?(:log_time, time_entry.project)
      render_403
      return
    end

    if time_entry.save
      @hamster.destroy!
      render json: time_entry
    else
      render nothing: true, status: 500
    end
  end

  private

  def stop_others
    HamsterIssue.my.each { |h| h.stop }
  end

  def find_issue
    @issue = Issue.find(params[:issue_id])
  end

  def find_hamster_issue
    @hamster_issue = HamsterIssue.my.where(id: params[:hamster_issue_id]).first
  end

  def find_hamster
    @hamster = Hamster.my.find(params[:id])
  end

  def prepare_data
    @hamster = Hamster.my.find(params[:hamster_id])
    @issue = @hamster.issue
    @project = @issue.project
    @hours = @hamster.spend_time
    @date = @hamster.start_at.to_date.try(:to_s)
  end

  def set_current_user
    fetched_user = User.joins(:api_token).where("tokens.value = '#{request.headers['X-Redmine-API-Key']}'").first
    if !request.headers['X-Redmine-API-Key'] || fetched_user.nil?
      render nothing: true, status: 401
    end
    User.current = fetched_user
  end

end
