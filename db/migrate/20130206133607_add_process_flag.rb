class AddProcessFlag < ActiveRecord::Migration
  def change
    add_column :upload_files, :file_processed, :boolean
    add_index :upload_files, :file_processed
  end
end
