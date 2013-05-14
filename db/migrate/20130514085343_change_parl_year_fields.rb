class ChangeParlYearFields < ActiveRecord::Migration
  def up
    add_column :parliaments, :start_year, :int
    add_column :parliaments, :end_year, :int
    add_index :parliaments, :start_year
    add_index :parliaments, :end_year

    remove_index :parliaments, :start_date
    remove_column :parliaments, :start_date
    remove_column :parliaments, :end_date

  end

  def down
    add_column :parliaments, :start_date, :date
    add_column :parliaments, :end_date, :date
    add_index :parliaments, :start_date

    remove_index :parliaments, :start_year
    remove_index :parliaments, :end_year
    remove_column :parliaments, :start_year
    remove_column :parliaments, :end_year
  end
end
