class AddLawUrlText < ActiveRecord::Migration
  def change
    add_column :agendas, :law_url_text, :binary, :limit => 16.megabyte #longblob
  end
end
