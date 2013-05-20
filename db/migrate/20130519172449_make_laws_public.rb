class MakeLawsPublic < ActiveRecord::Migration
  def up
    Agenda.transaction do
      # make all new laws public
      puts "making #{Agenda.where(:parliament_id => 2).count} laws public"
      start = Time.now
      index = 0
      Agenda.where(:parliament_id => 2).find_each(:batch_size => 100) do |agenda|
        puts "-- index = #{index} at #{Time.now}" if index % 100 == 0        
        index += 1
        agenda.not_update_vote_count = true
        agenda.is_public = 1
        agenda.made_public_at = Time.now
        if !agenda.valid?
          puts "*** agenda errors (#{agenda.xml_id}): #{agenda.errors.full_messages}"
          raise ActiveRecord::Rollback
          return
        end            
        agenda.save
      end
      puts "time to make laws public = #{Time.now - start} seconds"

      puts "updating vote count for delegates"
      AllDelegate.update_vote_counts(2)
    end
  end

  def down
    Agenda.where(:parliament_id => 2).update_all(:is_public => false)
    AllDelegate.update_vote_counts(2)
  end
end
