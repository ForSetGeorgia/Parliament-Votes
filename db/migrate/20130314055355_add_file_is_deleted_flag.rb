class AddFileIsDeletedFlag < ActiveRecord::Migration
  def change
    add_column :upload_files, :is_deleted, :boolean, :default => false
    add_column :upload_files, :deleted_at, :datetime
    add_column :upload_files, :deleted_by_id, :integer
    add_index :upload_files, :is_deleted
  end
end
