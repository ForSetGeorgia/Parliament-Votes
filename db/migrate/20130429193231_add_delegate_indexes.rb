class AddDelegateIndexes < ActiveRecord::Migration
  def change
    add_index :delegates, :first_name
    add_index :delegates, :xml_id
  end
end
