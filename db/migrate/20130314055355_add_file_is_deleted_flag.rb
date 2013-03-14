class AddFileIsDeletedFlag < ActiveRecord::Migration
  def change
    add_column :upload_files, :is_deleted, :boolean, :default => false
    add_index :upload_files, :is_deleted
  end
end
