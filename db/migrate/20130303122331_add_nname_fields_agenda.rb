class AddNnameFieldsAgenda < ActiveRecord::Migration
  def change
    add_column :agendas, :name2, :string
    add_column :agendas, :official_law_title, :string
    add_column :agendas, :law_description, :text
  end

end
