class AddParliamentIdAgendaData < ActiveRecord::Migration
  def up
    Agenda.update_all(:parliament_id => 1)
  end

  def down
    Agenda.update_all(:parliament_id => nil)
  end
end
