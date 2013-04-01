class AddAllDelId < ActiveRecord::Migration
  def change
    add_column :delegates, :all_delegate_id, :integer
    add_index :delegates, :all_delegate_id
    add_index :all_delegates, :first_name
  end
end
