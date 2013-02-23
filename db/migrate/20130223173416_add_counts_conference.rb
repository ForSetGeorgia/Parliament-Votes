class AddCountsConference < ActiveRecord::Migration
  def change  
    add_column :conferences, :number_laws, :integer
    add_column :conferences, :number_sessions, :integer
  end
end
