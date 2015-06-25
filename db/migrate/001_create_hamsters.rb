class CreateHamsters < ActiveRecord::Migration
  def change
    create_table :hamsters do |t|
      t.integer :user_id
      t.integer :issue_id
      t.datetime :start_at
      t.datetime :end_at
      t.float :spend_time
      t.timestamps null: false
    end
  end
end
