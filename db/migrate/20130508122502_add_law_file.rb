class AddLawFile < ActiveRecord::Migration
  def change
    add_column :agendas, :law_file_file_name, :string
    add_column :agendas, :law_file_content_type, :string
    add_column :agendas, :law_file_file_size, :integer
    add_column :agendas, :law_file_updated_at, :datetime
  end
end
