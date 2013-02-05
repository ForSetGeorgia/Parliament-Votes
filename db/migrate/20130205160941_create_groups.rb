class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.integer :conference_id
      t.string :text
      t.string :short_name

      t.timestamps
    end
    add_index :groups, :conference_id
  end
end
