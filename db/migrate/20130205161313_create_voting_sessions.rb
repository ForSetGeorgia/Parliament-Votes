class CreateVotingSessions < ActiveRecord::Migration
  def change
    create_table :voting_sessions do |t|
      t.integer :agenda_id
      t.boolean :passed
      t.boolean :quorum
      t.integer :result1, :default => 0
      t.integer :result3, :default => 0
      t.integer :result5, :default => 0
      t.string :result1text
      t.string :result3text
      t.string :result5text
      t.string :button1text
      t.string :button3text
      t.text :voting_conclusion

      t.timestamps
    end

    add_index :voting_sessions, :agenda_id 

  end
end
