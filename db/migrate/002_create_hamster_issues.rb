class CreateHamsterIssues < ActiveRecord::Migration
  def change
    create_table :hamster_issues do |t|
      t.integer :user_id
      t.integer :issue_id
      t.datetime :start_at
    end
  end
end
