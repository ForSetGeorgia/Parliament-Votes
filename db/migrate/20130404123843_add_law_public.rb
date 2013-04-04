class AddLawPublic < ActiveRecord::Migration
  def change
    add_column :agendas, :is_public, :boolean, :default => false
    add_index :agendas, :is_public
  end
end
