class AddDelegateCountFields < ActiveRecord::Migration
  def change
    add_column :all_delegates, :yes_count, :integer, :default => 0
    add_column :all_delegates, :no_count, :integer, :default => 0
    add_column :all_delegates, :abstain_count, :integer, :default => 0
    add_column :all_delegates, :absent_count, :integer, :default => 0

    add_index :all_delegates, :yes_count
    add_index :all_delegates, :no_count
    add_index :all_delegates, :abstain_count
    add_index :all_delegates, :absent_count
  end
end
