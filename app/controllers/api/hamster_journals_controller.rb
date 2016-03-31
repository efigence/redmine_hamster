class Api::HamsterJournalsController < ApplicationController
  unloadable

  accept_api_auth :hamster_journals, :update, :destroy

  before_filter :set_current_user

  before_action :find_journal_item, only: [:destroy, :update]

  skip_before_filter :check_if_login_required
  skip_before_filter :verify_authenticity_token

  def hamster_journals
    @journals = Hamster.find(params[:hamster_id]).hamster_journals
    render json: @journals
  end

  def destroy
    render json: { status: 200 } if @item.destroy
  end

  def update
    return render json: { status: 422 }, status: 422 if params[:from].blank? && params[:to].blank?
    from = params[:from].blank? ? @item.from : Time.parse(params[:from])
    to = params[:to].blank? ? @item.to : Time.parse(params[:to])
    summary = ((to - from) / 3600).round(1)
    previous_summary = @item.summary.to_f
    @item.update_attributes(from: from, to: to, summary: summary)
    @item.hamster.update_attributes(spend_time: (@item.hamster.spend_time + summary - previous_summary))
    render json: @item
  end

  private

  def find_journal_item
    @item = HamsterJournal.find(params[:id])
  end

  def set_current_user
    fetched_user = User.joins(:api_token).where("tokens.value = '#{request.headers['X-Redmine-API-Key']}'").first
    if !request.headers['X-Redmine-API-Key'] || fetched_user.nil?
      render nothing: true, status: 401
    end
    User.current = fetched_user
  end
end
