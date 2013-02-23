class AddCountsConference < ActiveRecord::Migration
  def change  
    add_column :conferences, :number_laws, :integer, :default => 0
    add_column :conferences, :number_sessions, :integer, :default => 0
  end
end
