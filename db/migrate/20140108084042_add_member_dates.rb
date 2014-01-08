class AddMemberDates < ActiveRecord::Migration
  def change
    add_column :all_delegates, :started_at, :date, :default => nil
    add_column :all_delegates, :ended_at, :date, :default => nil
    
    add_index :all_delegates, :started_at
    add_index :all_delegates, :ended_at
  end
end
