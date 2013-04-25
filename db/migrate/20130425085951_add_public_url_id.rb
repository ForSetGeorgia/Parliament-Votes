class AddPublicUrlId < ActiveRecord::Migration
  def change
    add_column :agendas, :public_url_id, :integer, :default => nil
    add_index :agendas, :public_url_id
  end
end
