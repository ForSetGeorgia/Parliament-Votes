# encoding: UTF-8
class AddOldRecords < ActiveRecord::Migration
  def up 
    puts "***************************************"
    puts "***************************************"
    puts "this migration assumes that the old records are in db called 'parl.ge'"
    puts "and that the db user for this app has read access to it"
    puts "***************************************"
    puts "***************************************"

    UploadFile.transaction do

      connection = ActiveRecord::Base.connection()

      # get party names
      puts 'get party names'
      sql = "select fraqcia_id, fraqcia_name from `parl.ge`.parl_fraqciebi where lang='geo' and mocveva_id = 6"
      parties = connection.execute(sql)

      # get unique dates and # of laws for each date
      puts 'getting unique dates and # of laws for each date'
      sql = "SELECT distinct kan_date, count(*) as count FROM `parl.ge`.`kanonebi` "
      sql << "where kan_date < '2012-08-01' and lang='geo' and kan_id in (select distinct kan_id from `parl.ge`.parl_voting_main) "
      sql << "group by kan_date ORDER BY `kanonebi`.`kan_date` ASC"
      dates = connection.execute(sql)

      # get votes per law
      puts 'getting votes per law'
      sql = "select k.kan_date, k.kan_id, x.count from `parl.ge`.kanonebi as k inner join ( "
      sql << "select kan_id, count(*) as count from `parl.ge`.parl_voting group by kan_id) as x on x.kan_id = k.kan_id "
      sql << "ORDER BY k.kan_id"
      vote_counts = connection.execute(sql)

      # get parl members
      puts 'getting parl members'
      sql = "SELECT cevri_id, concat(lastname, ' ', name) as name, fraqcia_id FROM `parl.ge`.`parl_cevrebi` "
      sql << "where mocveva_id = 6 and lang='geo'"
      members = connection.execute(sql)

      # get laws
      puts 'getting laws'
      sql = "SELECT kan_id, kan_name, kan_date, kan_num, kan_text, kan_file FROM `parl.ge`.`kanonebi` where kan_date < '2012-08-01' and lang='geo' and "
      sql << "kan_id in (select distinct kan_id from `parl.ge`.parl_voting_main) ORDER BY `kanonebi`.`kan_date` ASC"
      all_laws = connection.execute(sql)

      # get all delegates
      puts 'getting all delegates'
      all_delegates = AllDelegate.where(:parliament_id => 2)

      # add all missing delegates
      puts 'creating all delegate records'
      members.each do |member|
        # see if person has already been added
        ad_index = all_delegates.index{|x| x.xml_id == member[0]}

        # create all delegate record if needed
        if !ad_index.present?
          ad = AllDelegate.create(:xml_id => member[0], :first_name => member[1], :parliament_id => 2)
          all_delegates << ad
          ad_index = all_delegates.length-1
        end
      end

      laws_added = 0

      # create records
      dates.each_with_index do |d, d_index|
        date = d.to_a[0]
        puts "###### - laws added so far: #{laws_added} of #{all_laws.count}"

        puts "###################################################"
        puts "####### - new date: #{date}; #{d_index+1} of #{dates.count}"

        # get laws for this date
        puts '- getting laws for this date'
        laws = all_laws.select{|x| x[2] == date}

        if laws.present?
          puts "- found #{laws.length}"
          # create the file record
          puts "- creating file record"        
          file = UploadFile.create(:xml_file_name => 'transfer', :file_processed => 1,
            :parliament_id => 2, :number_possible_members => vote_counts.select{|x| x[0] == date}.first[2])

          # create conf record
          puts '- creating conference record'
          law_count = d.to_a[1]
          conf = file.create_conference(:upload_file_id => file.id, :start_date => date, :name => date, 
            :number_laws => law_count, :number_sessions => law_count)

          # create groups
          puts '- creating group records'
          parties.each do |party|
            conf.groups.create(:xml_id => party[0], :text => party[1], :short_name => party[1])
          end

          # create agenda for each law
          laws.each_with_index do |law, l_index|
            puts '-----------------'
            puts "------ law #{l_index+1} of #{laws.length}"
            # get votes for this law
            sql = "select cevr_id, result_id from `parl.ge`.parl_voting where kan_id = #{law[0]} ORDER BY cevr_id"
            votes = connection.execute(sql)

            if votes.present? && votes.count > 0
              puts "- law haw #{votes.count} votes"
              # create agenda
              puts '- creating agenda'
              # if law has file instead of law text, get the file
              law_file = nil
              if law[5].present? && law[5].strip.length > 0
                puts "--------> adding law_file: '#{law[5]}'"
                law_file_url = "http://test.parliament.ge/_special/kan/files/#{law[5]}"
                law_file = open(law_file_url)
                if law_file
                  # create the file name that paperclip will read in
                  extension = File.extname(URI.parse(law_file_url).path)
                  law_file.define_singleton_method(:original_filename) do
                    "#{law[3]}#{extension}"
                  end
                end
              end
              puts "--> law url text length = #{law[4].length}"
              agenda = conf.agendas.create(:xml_id => law[0], :name => law[1], :is_law => 1, :number_possible_members => file.number_possible_members,
                :law_id => law[3], :law_url_text => law[4], :official_law_title => law[1], :parliament_id => 2, :law_file => law_file)
              
              # create voting session
              puts '- creating voting session'
              voting_session = agenda.create_voting_session(:passed => 1, :quorum => 1)

              puts '- creating delegates/voting records'
              votes.each do |vote|
                # find the needed records
                m_index = members.to_a.index{|x| x[0] == vote[0]}
                if m_index.present?
                  member = members.to_a[m_index]
                  ad_index = all_delegates.index{|x| x.xml_id == member[0]}
                  g_index = conf.groups.index{|x| x.xml_id == member[2]}
                  # create delegate record
                  d = conf.delegates.create(:xml_id => member[0], :first_name => member[1],
                    :group_id => g_index.nil? ? nil : conf.groups[g_index].id, 
                    :all_delegate_id => ad_index.nil? ? nil : all_delegates[ad_index].id)

                  # create voting records
                  v = nil
                  case vote[1] 
                    when 1 # abstain
                      v = 0
                    when 51 # yes
                      v = 1
                    when 53 # no
                      v = 3
                  end
                  voting_session.voting_results.create(:delegate_id => d.id, :present => vote[1] == 5 ? 0 : 1, :vote => v)
                end
              end

              # update voting session reuslts
              puts "- updating voting session results"
              voting_session.update_results

              # make law public
              puts "- making law public"
              agenda.is_public = 1
              agenda.made_public_at = Time.now
              if !agenda.valid?
                puts "*** agenda errors (#{law[0]}): #{agenda.errors.full_messages}"
                raise ActiveRecord::Rollback
                return
              end            
              agenda.save
              laws_added += 1
            else
              puts "@@@@@@@@ law does not have any votes: #{law[0]}"
            end              
          end
        end
      end

      # update all delegate vote counts
      puts "updating all delegate vote count"
      AllDelegate.update_vote_counts(2)

    end
  end

  def down   
    UploadFile.transaction do
      UploadFile.where(:parliament_id => 2).each do |file|
        puts "deleting data for laws on #{file.conference.start_date}"
        file.unprocess_file 
        file.delete
      end
    end
  end
end
