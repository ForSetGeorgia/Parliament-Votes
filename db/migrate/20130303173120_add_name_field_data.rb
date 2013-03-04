class AddNameFieldData < ActiveRecord::Migration
  def up
    Agenda.laws_only(true).each do |agenda|
      agenda.generate_missing_data
      agenda.save
    end
  end

  def down
    Agenda.update_all(:law_title => nil, :official_law_title => nil, :law_description => nil)
  end
end
