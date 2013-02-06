class AddConfIdDelegates < ActiveRecord::Migration
  def change
    add_column :delegates, :conference_id, :integer
    add_index :delegates, :conference_id
  end
end
