class AddLawUrl < ActiveRecord::Migration
  def change
    add_column :agendas, :law_url, :string
  end
end
