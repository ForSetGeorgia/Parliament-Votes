class CreateParliaments < ActiveRecord::Migration
  def change
    create_table :parliaments do |t|
      t.string :name
      t.date :start_date
      t.date :end_date

      t.timestamps
    end

    add_index :parliaments, :name
    add_index :parliaments, :start_date
  end
end
