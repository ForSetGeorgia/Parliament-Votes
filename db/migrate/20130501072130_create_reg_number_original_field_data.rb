class CreateRegNumberOriginalFieldData < ActiveRecord::Migration
  def up
    Agenda.where('registration_number is not null').each do |a|
      a.registration_number_original = a.registration_number
      a.registration_number = a.registration_number.gsub(/[\(N\#\)]/, '').gsub(/\.\s/, ', ').gsub(';', ', ').gsub(/,\d/,', ')
      a.save
    end

  end

  def down
    Agenda.update_all(:registration_number_original => nil)
  end
end
