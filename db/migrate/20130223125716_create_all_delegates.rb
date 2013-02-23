class CreateAllDelegates < ActiveRecord::Migration
  def change
    create_table :all_delegates do |t|
      t.integer :xml_id
      t.integer :group_id
      t.string :first_name
      t.string :title

      t.timestamps
    end

    add_index :all_delegates, :xml_id
  end
end
