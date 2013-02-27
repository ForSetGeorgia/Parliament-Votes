class AddNumMembersFile < ActiveRecord::Migration
  def change
    add_column :upload_files, :number_possible_members, :integer, :default => 150
    add_index :upload_files,  :number_possible_members
  end
end
