namespace :clean_data do

	##############################
  desc "remove bad vote records for parliament members after 2013 bi-elections"
  task :remove_bi_elec_vote_records => [:environment] do

    AllDelegate.delete_vote_records_before_date(325, '2013-05-17')
    AllDelegate.delete_vote_records_before_date(326, '2013-05-17')
    AllDelegate.delete_vote_records_before_date(327, '2013-05-17')
  end



end
