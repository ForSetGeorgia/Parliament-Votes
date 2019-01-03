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

namespace :remove_duplicates do

  ##############################
  desc "duplicate vote result records are created if user double clicks the submit buttons"
  task :voting_results => [:environment] do

    start = Time.now

    conn = ActiveRecord::Base.connection

    # getting ids
    puts 'getting ids to delete - this will take some time...'
    id_results = conn.execute('select vr2.id from (select voting_session_id, delegate_id, count(*) as num  from voting_results group by voting_session_id, delegate_id having num > 1) as dups inner join voting_results as vr1 on vr1.voting_session_id = dups.voting_session_id and vr1.delegate_id = dups.delegate_id inner join voting_results as vr2 on vr2.voting_session_id = dups.voting_session_id and vr2.delegate_id = dups.delegate_id and vr1.id < vr2.id;')
    if id_results
      # pull out the ids
      ids = id_results.map{|x| x}.flatten

      puts "there are #{ids.length} duplicate records to delete"

      # delete records
      puts 'deleting duplicates'
      VotingResult.where(id: ids).delete_all
    end

    # reset counts
    puts "reseting law vote counts"
    [1,3].each do |parliament_id|
      Agenda.update_law_vote_results(parliament_id)
      AllDelegate.update_vote_counts(parliament_id)
    end
    FileUtils.rm_rf(AllDelegate::JSON_API_PATH)

    puts "TOTAL TIME = #{Time.now - start} seconds"

  end

end
