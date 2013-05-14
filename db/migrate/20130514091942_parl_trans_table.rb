class ParlTransTable < ActiveRecord::Migration
  def up
    rename_column :parliaments, :name, :name_old
		Parliament.create_translation_table! :name => :string
    add_index :parliament_translations, :name
  end

  def down
    rename_column :parliaments, :name_old, :name
		Parliament.drop_translation_table!
  end
end
