class ChangeParlYearFieldsData < ActiveRecord::Migration
  def up
    p = Parliament.find(2)
    p.start_year = 2008
    p.end_year = 2012
    p.save

    p = Parliament.find(1)
    p.start_year = 2012
    p.end_year = 2016
    p.save
  end

  def down
    Parliament.update_all(:start_year => nil, :end_year => nil)
  end
end
