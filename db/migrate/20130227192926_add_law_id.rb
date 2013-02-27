class AddLawId < ActiveRecord::Migration
  def change
    add_column :agendas, :law_id, :string
    add_index :agendas, :law_id
    add_index :agendas, :law_url
  end
end
