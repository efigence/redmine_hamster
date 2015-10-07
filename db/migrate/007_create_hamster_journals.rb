class CreateHamsterJournals < ActiveRecord::Migration
  def change
    create_table :hamster_journals do |t|
      t.integer :hamster_id
      t.integer :user_id
      t.string :from
      t.string :to
      t.string :summary
    end
  end
end
