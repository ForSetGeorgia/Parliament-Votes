class CleanUpVersions < ActiveRecord::Migration
  def up
    Version.transaction do 
      version_ids = []
    
      ########################
      # agendas
      ########################
      puts "- testing agendas"
      Agenda.all.each do |record|
        puts "----------------------"
        puts "----------------------"
        puts "----------------------"
#        puts "-- record: #{record.attributes.except('updated_at', 'impressions_count').inspect}"
        updates = record.versions.select{|x| x.event == 'update'}
        if updates.present?
          puts "--- record #{record.id} has #{updates.length} version update records"
          
          update_ids = []
          
          # check for duplicate versions against current version, ignoring count changes
          puts "--- checking for duplicates with current version"
          (updates.length-1).downto(0) do |index|
            begin 
              previous_record = updates[index].reify
  #            puts "--- previous record: #{previous_record.attributes.except('updated_at', 'impressions_count').inspect}"
              if record.attributes.except('updated_at', 'impressions_count') ==
                  previous_record.attributes.except('updated_at', 'impressions_count')
                
  #              puts "---- **** found a repeat: #{updates[index].id}"
                # found a repeat
                version_ids << updates[index].id
                update_ids << updates[index].id 
              end
            rescue Psych::SyntaxError
              puts "+++++++++++++++++++++++++++++++++"
              puts "+++++++++++++++++++++++++++++++++"
              puts "could not reify version so skipping"
              puts "+++++++++++++++++++++++++++++++++"
              puts "+++++++++++++++++++++++++++++++++"
            end
          end
          
          # now check for duplicates between old versions (not compared with current version as above)
          # - only check records that were not found as a repeat above
          puts "--- checking for duplicates among old versions"
          updates = updates.select{|x| update_ids.index(x.id).nil?}
          if updates.present? && updates.length > 1
            (updates.length-1).downto(1) do |index|
              begin 
                record = updates[index].reify
                (index-1).downto(0) do |index2|
                  previous_record = updates[index2].reify
                  
                  if record.attributes.except('updated_at', 'impressions_count') ==
                      previous_record.attributes.except('updated_at', 'impressions_count')
                    
  #                  puts "---- **** found a repeat among old versions: #{updates[index2].id}"
                    # found a repeat
                    version_ids << updates[index2].id
                  end
                end
              rescue Psych::SyntaxError
                puts "+++++++++++++++++++++++++++++++++"
                puts "+++++++++++++++++++++++++++++++++"
                puts "could not reify version so skipping"
                puts "+++++++++++++++++++++++++++++++++"
                puts "+++++++++++++++++++++++++++++++++"
              end
            end
          end

        end
      end

      puts "*********************************"
      puts "*********************************"
      puts "*********************************"
    
      ########################
      # all delegates
      ########################
      puts "- testing all delegates"
      AllDelegate.all.each do |record|
        puts "----------------------"
        puts "----------------------"
        puts "----------------------"
#        puts "-- record: #{record.inspect}"
        updates = record.versions.select{|x| x.event == 'update'}
        if updates.present?
          puts "--- record #{record.id} has #{updates.length} version update records"

          update_ids = []
          
          # check for duplicate versions against current version, ignoring count changes
          puts "--- checking for duplicates with current version"
          (updates.length-1).downto(0) do |index|
            begin 
              previous_record = updates[index].reify
  #            puts "--- previous record: #{previous_record.inspect}"
              if record.attributes.except('updated_at', 'impressions_count', 'vote_count', 'yes_count', 'no_count', 'abstain_count', 'absent_count') ==
                  previous_record.attributes.except('updated_at', 'impressions_count', 'vote_count', 'yes_count', 'no_count', 'abstain_count', 'absent_count')
                
  #              puts "---- **** found a repeat: #{updates[index].id}"
                # found a repeat
                version_ids << updates[index].id
                update_ids << updates[index].id 
              end
            rescue Psych::SyntaxError
              puts "+++++++++++++++++++++++++++++++++"
              puts "+++++++++++++++++++++++++++++++++"
              puts "could not reify version so skipping"
              puts "+++++++++++++++++++++++++++++++++"
              puts "+++++++++++++++++++++++++++++++++"
            end
          end

          
          # now check for duplicates between old versions (not compared with current version as above)
          # - only check records that were not found as a repeat above
          puts "--- checking for duplicates among old versions"
          updates = updates.select{|x| update_ids.index(x.id).nil?}
          if updates.present? && updates.length > 1
            (updates.length-1).downto(1) do |index|
              begin 
                record = updates[index].reify
                (index-1).downto(0) do |index2|
                  previous_record = updates[index2].reify
                  
                  if record.attributes.except('updated_at', 'impressions_count', 'vote_count', 'yes_count', 'no_count', 'abstain_count', 'absent_count') ==
                      previous_record.attributes.except('updated_at', 'impressions_count', 'vote_count', 'yes_count', 'no_count', 'abstain_count', 'absent_count')
                    
  #                  puts "---- **** found a repeat among old versions: #{updates[index2].id}"
                    # found a repeat
                    version_ids << updates[index2].id
                  end
                end
              rescue Psych::SyntaxError
                puts "+++++++++++++++++++++++++++++++++"
                puts "+++++++++++++++++++++++++++++++++"
                puts "could not reify version so skipping"
                puts "+++++++++++++++++++++++++++++++++"
                puts "+++++++++++++++++++++++++++++++++"
              end
            end
          end
        end
      end


      # delete unnecessary versions
      puts "- deleting #{version_ids.uniq.length} version records"
#      Version.where(:id => version_ids.uniq).delete_all
    end
  end

  def down
    # do nothing
  end
end
