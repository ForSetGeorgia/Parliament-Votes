class AddAgendaIndexes < ActiveRecord::Migration
  def change
    add_index :agendas, :session_number1_id
    add_index :agendas, :session_number2_id
    add_index :agendas, :session_number
    add_index :agendas, :registration_number
    add_index :agendas, :official_law_title
  end
end
