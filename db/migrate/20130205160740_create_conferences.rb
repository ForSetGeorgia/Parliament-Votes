class CreateConferences < ActiveRecord::Migration
  def change
    create_table :conferences do |t|
      t.date :start_date
      t.string :name
      t.integer :conference_label

      t.timestamps
    end

    add_index :conferences, [:start_date, :name]

  end
end
