class HamsterJournalsController < ApplicationController
  unloadable

  before_action :find_journal_item, only: [:destroy, :update]

  def destroy
    @item.destroy
    render nothing: true
  end

  def update
    @item.update_attributes(from: Time.parse(params[:hamster_journal][:from]),
                            to: Time.parse(params[:hamster_journal][:to]),
                            summary: params[:hamster_journal][:summary])
    @item.hamster.update_attributes(spend_time: params[:hamster_journal][:hamster_sum])
    render nothing: true
  end

  private

  def find_journal_item
    @item = HamsterJournal.find(params[:id])
  end
end
