class RemoveDuplicateVoteResults < ActiveRecord::Migration
  def up
    VotingResult.transaction do
      puts "- looking for duplicates"
      sql = "select voting_session_id, delegate_id, present, vote, max(id) as id from voting_results group by voting_session_id, delegate_id, present, vote having count(*) > 1"
      duplicates = VotingResult.find_by_sql(sql)

      # have to do loop to catch the cases where the are more than 2 duplicates
      until duplicates.length == 0      
        if duplicates.present?
          puts "- found #{duplicates.length} duplicates"
          puts "- deleting..."
          VotingResult.where(:id => duplicates.map{|x| x.id}).delete_all
          puts "- done!"
        end

        puts "- looking for more duplicates"
        duplicates = VotingResult.find_by_sql(sql)
      end

      puts "-----------------"

      # update vote counts for people
      Parliament.all.each do |p|
        puts "- updating vote counts for parl #{p.id}"
        AllDelegate.update_vote_counts(p.id)
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
