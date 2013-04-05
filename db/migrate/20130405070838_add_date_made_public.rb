class AddDateMadePublic < ActiveRecord::Migration
  def change
    add_column :agendas, :made_public_at, :datetime
    add_index :agendas, :made_public_at
  end
end
