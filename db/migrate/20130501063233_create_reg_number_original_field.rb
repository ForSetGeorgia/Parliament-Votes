class CreateRegNumberOriginalField < ActiveRecord::Migration
  def change
    add_column :agendas, :registration_number_original, :string
  end
end
