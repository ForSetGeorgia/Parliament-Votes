class RemoveDuplicateVoteResults < ActiveRecord::Migration
  def up
    VotingResult.transaction do
      voting_session_ids = []

      puts "-----------------"
      puts "- looking for delegate records for same person in conference that has multiple records "
      # possible that there are duplicate delegate records too, but with different delegate ids
      # find them and remove duplicate delegate record and voting result record

      sql = "select conference_id, xml_id, all_delegate_id, min(id) as good_id, max(id) as id from delegates group by conference_id, xml_id, all_delegate_id having count(*) > 1 order by id asc"
      duplicates = Delegate.find_by_sql(sql)
      # have to do loop to catch the cases where there are more than 2 duplicates
      
      loop_count = 0
      until duplicates.length == 0      
        puts "---"
        puts "- found #{duplicates.length} duplicates"

        puts "- getting voting records that need to be updated"
        results = VotingResult.where(:delegate_id => duplicates.map{|x| x.id}).order('delegate_id asc')
        puts "- found #{results.length} voting results"
        
        if results.present?
          # save session id so can update vote counts at end
          voting_session_ids << results.map{|x| x.voting_session_id}.uniq

          puts "- updating voting results"
          # update vote results to use good_id for delegate id
          x = 0
          results.each do |result|
            delegate = duplicates.select{|x| x.id == result.delegate_id}
            if delegate.present?
              result.delegate_id = delegate.first[:good_id]
              result.save
              x += 1
            end
#            x = VotingResult.update(results.map{|x| x.id}, duplicates.select{|x| results.map{|y| y.delegate_id}.index(x.id).present?}.map{|x| {:delegate_id => x[:good_id]}})
          end
        end
        
        puts "- deleting duplicate delegates"
        # delete the duplicate delegate record 
        y = Delegate.where(:id => duplicates.map{|x| x.id}).delete_all

        puts "- done - updated #{x} voting result records and deleted #{y} delegate records"
        
        puts "- looking for more duplicates"
        duplicates = Delegate.find_by_sql(sql)

        loop_count += 1
      end

      puts "-> took #{loop_count} loops to clear all duplicates "
      

      puts "-----------------"

      puts "- looking for duplicates voting result records for same person in voting session"
      sql = "select voting_session_id, delegate_id, present, vote, max(id) as id from voting_results group by voting_session_id, delegate_id, present, vote having count(*) > 1"

      duplicates = VotingResult.find_by_sql(sql)
      
      # have to do loop to catch the cases where there are more than 2 duplicates
      loop_count = 0
      until duplicates.length == 0      
        puts "---"
        # save session id so can update vote counts at end
        voting_session_ids << duplicates.map{|x| x.voting_session_id}.uniq

        puts "- found #{duplicates.length} duplicates"
        puts "- deleting..."
        x = VotingResult.where(:id => duplicates.map{|x| x.id}).delete_all
        puts "- done - deleted #{x} records"

        puts "- looking for more duplicates"
        duplicates = VotingResult.find_by_sql(sql)
        
        loop_count += 1
      end

      puts "-> took #{loop_count} loops to clear all duplicates "


      puts "-----------------"


      # update vote counts for people
      Parliament.all.each do |p|
        puts "- updating vote counts for parl #{p.id}"
        AllDelegate.update_vote_counts(p.id)
      end
      
      # update vote counts for laws
      ids = voting_session_ids.flatten.uniq
      if ids.present?
        puts "- updating vote counts for #{ids.length} vote session records"
        VotingSession.where(:id => ids).each do |session|
          session.update_results
        end
      end
                  
      # kill the api json
      puts "- killing api json files"
      FileUtils.rm_rf(AllDelegate::JSON_API_PATH)
      
    end
  end

  def down
    # do nothing
  end
end
