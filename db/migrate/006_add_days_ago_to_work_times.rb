class AddDaysAgoToWorkTimes < ActiveRecord::Migration
  def up
    add_column :work_times, :days_ago, :integer
  end

  def down
    remove_column :work_times, :days_ago
  end
end