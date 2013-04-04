class AddParlIdDelegates < ActiveRecord::Migration
  def change
    add_column :all_delegates, :parliament_id, :integer
    add_index :all_delegates, :parliament_id 
  end
end
