class AddAbsentDelegatesJoinedSessions < ActiveRecord::Migration
  def up
    laws = Agenda.public_laws

    if laws.present?
      Agenda.transaction do 
        laws.each do |law|    
          puts "processing law ##{law.id}"
          # if this law has an assigned session1 and session2, add missing delegate records to those too
          sessions = [law.session_number1_id, law.session_number2_id]
          sessions.each do |session|
            if session.present?
              attached_session = Agenda.find_by_id(session)
              if attached_session.present?
                delegates = AllDelegate.available_delegates(attached_session.id)
                if delegates.present?
                  puts "  - adding missing delegates to session #{session}"
                  delegates.each do |member|
                    # see if delegate record already exists
                    d = Delegate.where(:conference_id => attached_session.conference_id, :all_delegate_id => member.id)
                    del = nil
                    if d.present?
                      del = d.first
                    else
                      del = Delegate.create(:conference_id => attached_session.conference_id, :xml_id => member.xml_id, 
                        :group_id => member.group_id,
                        :first_name => member.first_name,
                        :all_delegate_id => member.id)
                    end

                    # now save voting result record
                    if del.present?
                      VotingResult.create(:voting_session_id => attached_session.voting_session.id, 
                                :delegate_id => del.id,
                                :present => false,
                                :is_manual_add => true)
                    end
                  end
                end
              end
            end
          end
        end
        # update vote count
        AllDelegate.update_vote_counts(1)
      end
    end    
  end

  def down
    # do nothing
  end
end
