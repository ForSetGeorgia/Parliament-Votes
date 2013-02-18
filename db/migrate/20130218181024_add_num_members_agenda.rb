class AddNumMembersAgenda < ActiveRecord::Migration
  def change
    add_column :agendas, :number_possible_members, :integer, :default => 150
    add_index :agendas,  :number_possible_members
  end
end
