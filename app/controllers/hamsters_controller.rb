class HamstersController < ApplicationController
  unloadable

  before_action :find_issue,   only: [:start]
  before_action :find_hamster, only: [:update, :destroy]
  before_action :find_hamster_issue, only: [:stop]


  def index
    @active_hamsters = HamsterIssue.my
    @raport_hamsters = Hamster.my.group_by {|h| h.created_at.to_date }
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

  private

  def find_issue
    @issue = Issue.my_open.find(params[:issue_id])
  end

  def find_hamster_issue
    @hamster_issue = HamsterIssue.my.find(params[:hamster_issue_id])
  end

  def find_hamster
    @hamster = Hamster.my.find(params[:id])
  end

end
