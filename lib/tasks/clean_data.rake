namespace :clean_data do

	##############################
  desc "remove bad vote records for parliament members after 2013 bi-elections"
  task :remove_bi_elec_vote_records => [:environment] do
    ad = AllDelegate.find_by_id(325)
    ad.delete_vote_records_outside_of_date('2013-05-17', '<')
    ad = AllDelegate.find_by_id(326)
    ad.delete_vote_records_outside_of_date('2013-05-17', '<')
    ad = AllDelegate.find_by_id(327)
    ad.delete_vote_records_outside_of_date('2013-05-17', '<')
  end



end
