class CreateUploadFiles < ActiveRecord::Migration
  def change
    create_table :upload_files do |t|
      t.string :xml_file_name
      t.string :xml_content_type
      t.string :xml_file_size
      t.string :xml_updated_at

      t.timestamps
    end

    add_column :conferences, :upload_file_id, :integer
    add_index :conferences, :upload_file_id

  end
end
