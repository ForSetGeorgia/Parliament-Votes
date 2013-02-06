class AddXmlIds < ActiveRecord::Migration
  def change
    add_column :groups, :xml_id, :integer
    add_column :delegates, :xml_id, :integer
    add_column :agendas, :xml_id, :integer
    add_column :voting_sessions, :xml_id, :integer
    
  end

end
