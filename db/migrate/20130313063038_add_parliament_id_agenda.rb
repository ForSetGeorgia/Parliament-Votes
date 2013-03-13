class AddParliamentIdAgenda < ActiveRecord::Migration
  def change
    add_column :agendas, :parliament_id, :integer
    add_index :agendas, :parliament_id
  end
end
