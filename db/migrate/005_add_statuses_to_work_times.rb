
class AddStatusesToWorkTimes < ActiveRecord::Migration
  def up
    add_column :work_times, :start_status_to, :integer
    add_column :work_times, :stop_status_to, :integer
  end

  def down
    remove_column :work_times, :start_status_to
    remove_column :work_times, :stop_status_to
  end
end
