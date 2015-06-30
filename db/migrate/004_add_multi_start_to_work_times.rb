class AddMultiStartToWorkTimes < ActiveRecord::Migration
  def up
    add_column :work_times, :multi_start, :boolean, default: false
  end

  def down
    remove_column :work_times, :multi_start
  end
end
