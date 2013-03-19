class AddSessionIdFields < ActiveRecord::Migration
  def change
    add_column :agendas, :session_number1_id, :integer
    add_column :agendas, :session_number2_id, :integer
  end
end
