class AddShowCurrentIssueToWorkTimes < ActiveRecord::Migration
  def up
    add_column :work_times, :show_current_issue, :boolean, default: false
  end

  def down
    remove_column :work_times, :show_current_issue
  end
end
