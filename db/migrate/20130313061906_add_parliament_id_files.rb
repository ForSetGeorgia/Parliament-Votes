class AddParliamentIdFiles < ActiveRecord::Migration
  def change
    add_column :upload_files, :parliament_id, :integer
    add_index :upload_files, :parliament_id
  end

end
