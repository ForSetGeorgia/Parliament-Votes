class CreateAgendas < ActiveRecord::Migration
  def change
    create_table :agendas do |t|
      t.integer :conference_id
      t.integer :sort_order, :default => 0
      t.integer :level
      t.string :name
      t.text :description

      t.timestamps
    end

    add_index :agendas, :conference_id
    add_index :agendas, [:sort_order, :name]

  end
end
