class HamstersController < ApplicationController
  unloadable

  before_action :find_issue,   only: [:start]
  before_action :find_hamster, only: [:update, :destroy]
  before_action :find_hamster_issue, only: [:stop]
  before_action :prepare_data, only: [:raport_time]

  def index
    @active_hamsters = HamsterIssue.my
    @raport_hamsters = Hamster.my.group_by {|h| h.start_at.to_date }
  end

  def start
    HamsterIssue.start(@issue.id)
    redirect_to hamsters_index_url
  end

  def stop
    @hamster_issue.stop
    redirect_to hamsters_index_url
  end

  def update
    @hamster.update_attributes(spend_time: params[:hamster][:spend_time])
  end

  def destroy
    @hamster.destroy
  end

  def raport_time
    time_entry = TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => @date)
    time_entry.safe_attributes = params[:time_entry]

    if time_entry.project && !User.current.allowed_to?(:log_time, time_entry.project)
      render_403
      return
    end

    if time_entry.save
      @hamster.destroy!
    else
      respond_to do |format|
        format.html { render :action => 'index' }
        format.api  { render_validation_errors(time_entry) }
      end
    end
  end

  private

  def find_issue
    @issue = Issue.find(params[:issue_id])
  end

  def find_hamster_issue
    @hamster_issue = HamsterIssue.my.find(params[:hamster_issue_id])
  end

  def find_hamster
    @hamster = Hamster.my.find(params[:id])
  end

  def prepare_data
    @issue = Issue.find(params[:time_entry][:issue_id])
    @project = @issue.project
    @date = params[:time_entry][:spent_on]
    @hamster =  Hamster.my.find(params[:time_entry][:hamster_id])
  end

end