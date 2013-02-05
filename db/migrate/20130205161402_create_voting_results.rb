class CreateVotingResults < ActiveRecord::Migration
  def change
    create_table :voting_results do |t|
      t.integer :voting_session_id
      t.integer :delegate_id
      t.boolean :present
      t.integer :vote
      t.integer :weight

      t.timestamps
    end

    add_index :voting_results, :voting_session_id
    add_index :voting_results, :delegate_id


  end
end
