class CreateDelegates < ActiveRecord::Migration
  def change
    create_table :delegates do |t|
      t.integer :group_id
      t.string :first_name
      t.string :title

      t.timestamps
    end

    add_index :delegates, :group_id

  end
end
