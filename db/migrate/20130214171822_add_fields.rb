class AddFields < ActiveRecord::Migration
  def change
    add_column :agendas, :is_law, :boolean, :default => false
    add_column :agendas, :registration_number, :string
    add_column :agendas, :session_number, :string

    add_index :agendas, :is_law
  end
end
