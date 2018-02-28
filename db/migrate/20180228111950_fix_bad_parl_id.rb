class FixBadParlId < ActiveRecord::Migration
  def up
    # agenda 26408 has parliament_id of 3 but it should be 1
    Agenda.transaction do
      a = Agenda.find(26408)

      if a.present?
        puts "found agenda, updating parliament id"
        # update parliament id
        a.parliament_id = 1
        a.save

        # get all delegate ids for parl id 3
        all_delegate_ids = AllDelegate.where(parliament_id: 3).pluck(:id)

        if all_delegate_ids.present?
          # remove delegates that were not in parliament 1
          delegates = Delegate.where(conference_id: a.conference_id, all_delegate_id: all_delegate_ids)

          if delegates.present?
            puts "found #{delegates.length} delegates to delete"
            delegates.destroy_all
            puts "finished deleting delegates"
          end

        end
      end

      # update the delegate records
      puts "adding in missing delegates"
      a.not_update_vote_count = true
      a.update_records_for_public_law(true)

      # reset counts
      puts "reseting counts"
      [1,3].each do |parliament_id|
        Agenda.update_law_vote_results(parliament_id)
        AllDelegate.update_vote_counts(parliament_id)
      end
      FileUtils.rm_rf(AllDelegate::JSON_API_PATH)
    end
  end

  def down
    puts 'do nothing'
  end
end
