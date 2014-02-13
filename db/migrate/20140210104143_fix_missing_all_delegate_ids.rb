class FixMissingAllDelegateIds < ActiveRecord::Migration
  def up
    Delegate.transaction do
      puts "- first fix delegate records that are missing all_delegate_id"
      delegates = Delegate.select('id, xml_id').where("all_delegate_id is null")
      puts "- found #{delegates.length} records that need to be fixed"
      count = 0
      if delegates.present?
        delegate_ids = delegates.map{|x| x.xml_id}.uniq
        puts "- #{delegate_ids.length} delegates account for all of these records"
        
        if delegate_ids.present?
          all_delegates = AllDelegate.where(:xml_id => delegate_ids)
          puts "- could only find #{all_delegates.length} delegates in the all delegates table"
        
          if all_delegates.present?
            all_delegates.each do |ad|
              count += Delegate.where("xml_id = ? and all_delegate_id is null", ad.xml_id).update_all(:all_delegate_id => ad.id)
            end
          end
        end
      end
      puts "- fixed #{count} records, the remaining delegate records do not have all delegate record "


      # update vote counts for people
      Parliament.all.each do |p|
        puts "- updating vote counts for parl #{p.id}"
        AllDelegate.update_vote_counts(p.id)
      end
      
      # update vote counts for laws
      sessions = VotingResult.select('voting_session_id').where("delegate_id in (?)", delegates.map{|x| x.id}.uniq) 
      if sessions.present?
        puts "- updating vote counts for #{sessions.length} vote session records"
        VotingSession.where(:id => sessions.map{|x| x.voting_session_id}).each do |session|
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
