namespace :reprocess_data do

	##############################
  desc "look for registration numbers that were missed before"
  task :registration_numbers => [:environment] do

    Agenda.reprocess_registration_number
  end

	##############################
  desc "look for items that were not marked as laws before but could be a law"
  task :laws => [:environment] do

    Agenda.reprocess_items_not_laws
  end


end
