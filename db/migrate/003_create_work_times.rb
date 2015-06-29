class CreateWorkTimes < ActiveRecord::Migration
  def change
    create_table :work_times do |t|
      t.integer :user_id
      t.time :start_at
      t.time :end_at
    end
  end
end
