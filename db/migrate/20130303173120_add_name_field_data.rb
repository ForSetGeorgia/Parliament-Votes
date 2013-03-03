class AddNameFieldData < ActiveRecord::Migration
  def up
    Agenda.laws_only(true).each do |agenda|
      # recreate reg number for new patterns were found
      agenda.generate_registration_number
      
      agenda.generate_official_law_title
      agenda.generate_law_description
      agenda.generate_law_title
      agenda.save
    end
  end

  def down
    Agenda.update_all(:law_title => nil, :official_law_title => nil, :law_description => nil)
  end
end
