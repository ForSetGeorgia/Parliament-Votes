old_logger = ActiveRecord::Base.logger
ActiveRecord::Base.logger = nil

parl_id = 3
members = [
  {id: [6105, 61318], law_votes: 0, non_law_votes: 0}, 
  {id: [61145, 61289], law_votes: 0, non_law_votes: 0}, 
  {id: [61189, 61341], law_votes: 0, non_law_votes: 0}, 
  {id: [61196, 61349], law_votes: 0, non_law_votes: 0}, 
  {id: [61144, 61288], law_votes: 0, non_law_votes: 0}, 
  {id: [61119, 61259], law_votes: 0, non_law_votes: 0}, 
  {id: [61110, 61250], law_votes: 0, non_law_votes: 0}, 
  {id: [61179, 61328], law_votes: 0, non_law_votes: 0}, 
  {id: [61182, 61333], law_votes: 0, non_law_votes: 0}, 
  {id: [61108, 61248], law_votes: 0, non_law_votes: 0}, 
  {id: [61141, 61284], law_votes: 0, non_law_votes: 0}, 
  {id: [61192, 61344], law_votes: 0, non_law_votes: 0}, 
  {id: [62454], law_votes: 0, non_law_votes: 0} 
]

# get files assigned to this parliament
files = UploadFile.where(parliament_id: parl_id).not_deleted
puts "There are #{files.length} files for 9th Parliament"

if files.present?

  files.each do |file|
    puts "------------------------"
    puts "file: #{file.xml_file_name}"
    if file.conference.present?
      # get the laws in this file
      agendas = file.conference.agendas
      delegates = file.conference.delegates
      laws = agendas.select{|x| x.is_law} if agendas.present?
      non_laws = agendas.select{|x| !x.is_law} if agendas.present?

      puts "- agendas: #{agendas.empty? ? 0 : agendas.length}"
      puts "- law agendas: #{laws.empty? ? 0 : laws.length}"
      puts "- non-law agendas: #{non_laws.empty? ? 0 : non_laws.length}"
      
      # get the vote counts on laws
      if laws.present?
        puts "----"
        puts "processing law votes"
        voting_results = laws.select{|x| x.voting_session.present?}.map{|a| a.voting_session.voting_results}.flatten


        members.each do |member|
          puts "- member: #{member}"
          delegate_ids = delegates.select{|x| member[:id].include? x.xml_id}.map{|x| x.id}
          if delegate_ids.present?
            votes = voting_results.select{|x| delegate_ids.include? x.delegate_id}
            member[:law_votes] += votes.empty? ? 0 : votes.length
          else
            puts "-- DELEGATE ID NOT FOUND"
          end
        end

      end

      # get the vote counts on non-laws
      if non_laws.present?
        puts "----"
        puts "processing non-law votes"
        voting_results = non_laws.select{|x| x.voting_session.present?}.map{|a| a.voting_session.voting_results}.flatten


        members.each do |member|
          puts "- member: #{member}"
          delegate_ids = delegates.select{|x| member[:id].include? x.xml_id}.map{|x| x.id}
          if delegate_ids.present?
            votes = voting_results.select{|x| delegate_ids.include? x.delegate_id}
            member[:non_law_votes] += votes.empty? ? 0 : votes.length
          else
            puts "-- DELEGATE ID NOT FOUND"
          end
        end

      end
    else
      puts"-- FILE HAS NO CONFERENCE"
    end

  end
end

puts "=================="
puts members

ActiveRecord::Base.logger = old_logger