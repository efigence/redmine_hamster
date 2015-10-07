class AddIssueIdToHamsterJournal < ActiveRecord::Migration
  def up
    add_column :hamster_journals, :issue_id, :integer
  end

  def down
    remove_column :hamster_journals, :issue_id
  end
end