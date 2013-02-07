class UploadFile < ActiveRecord::Base
  
  has_one :conference, :dependent => :destroy
  accepts_nested_attributes_for :conference

	attr_accessible :xml, :xml_file_name, :xml_content_type, :xml_file_size, :xml_updated_at, :conference_attributes, :file_processed

  validates :xml_file_name, :presence => true

	has_attached_file :xml, :url => "/system/upload_files/:id/:filename"
  

  def unprocess_file
    # voting session & voting results
    if self.conference.present?
      self.conference.agendas.each do |agenda|
        agenda.voting_sessions.each do |session|
          session.voting_results.delete_all
        end
        agenda.voting_sessions.delete_all
      end

      # agenda
      self.conference.agendas.delete_all

      # delegates
      self.conference.delegates.delete_all

      # groups 
      self.conference.groups.delete_all

      # conference
      self.conference.delete
    end

    self.file_processed = false
    self.save
  end


  def process_file
    if !self.file_processed

      file = File.open("#{Rails.root}/public#{self.xml.url(:original,false)}")

      doc = Nokogiri::XML(file)

      UploadFile.transaction do
        # conference
        conf = doc.at_css('Conference')
        if conf.present?
          conference = self.create_conference(:start_date => conf.at_css('StartDate').text[0..9], 
            :name => conf.at_css('name').text, 
            :conference_label => conf.at_css('conferenceLabel').text
          )

          # groups
          doc.css('Group').each do |group|
            g = conference.groups.create(:xml_id => group.at_css('id').text, 
              :text => group.at_css('Text').text, 
              :short_name => group.at_css('ShortName').text
            )
          end

          # delegates
          doc.css("Delegate").each do |delegate|
            group_index = conference.groups.index{|x| x.xml_id.to_s == delegate.at_css('Group_id').text} if !delegate.at_css('Group_id').nil?
            d = conference.delegates.create(:xml_id => delegate.at_css('id').text, 
              :group_id => group_index.nil? ? nil : conference.groups[group_index].id, 
              :first_name => delegate.at_css('firstname').nil? ? nil : delegate.at_css('firstname').text, 
              :title => delegate.at_css('title').nil? ? nil : delegate.at_css('title').text 
            )
          end

          # agendas
          doc.css('Agenda').each do |agenda|
            ag = conference.agendas.create(:xml_id => agenda.at_css('id').text, 
              :sort_order => agenda.at_css('SortOrder').nil? ? nil : agenda.at_css('SortOrder').text, 
              :level => agenda.at_css('Level').nil? ? nil : agenda.at_css('Level').text, 
              :name => agenda.at_css('Name').nil? ? nil : agenda.at_css('Name').text, 
              :description => agenda.at_css('Description').nil? ? nil : agenda.at_css('Description').text
            )

            # add voting sessions for agenda          
            doc.xpath("//VotingSession/Agenda_id[contains(text(), '#{ag.xml_id}')]/..").each do |session|
              vs = ag.voting_sessions.create(:xml_id => session.at_css('id').text, 
                :agenda_id => session.at_css('Agenda_id').nil? ? nil : session.at_css('Agenda_id').text, 
                :passed => session.at_css('Passed').nil? ? nil : session.at_css('Passed').text, 
                :quorum => session.at_css('Quorum').nil? ? nil : session.at_css('Quorum').text,
                :result1 => session.at_css('Result1').nil? ? nil : session.at_css('Result1').text,
                :result3 => session.at_css('Result3').nil? ? nil : session.at_css('Result3').text,
                :result5 => session.at_css('Result5').nil? ? nil : session.at_css('Result5').text,
                :result1text => session.at_css('Result1Text').nil? ? nil : session.at_css('Result1Text').text,
                :result3text => session.at_css('Result3Text').nil? ? nil : session.at_css('Result3Text').text,
                :result5text => session.at_css('Result5Text').nil? ? nil : session.at_css('Result5Text').text,
                :button1text => session.at_css('Button1Text').nil? ? nil : session.at_css('Button1Text').text,
                :button3text => session.at_css('Button3Text').nil? ? nil : session.at_css('Button3Text').text,
                :voting_conclusion => session.at_css('VotingConclusion').nil? ? nil : session.at_css('VotingConclusion').text
              )

              # add voting results
              doc.xpath("//VotingResult/VotingSession_id[contains(text(), '#{vs.xml_id}')]/..").each do |result|
                del_index = conference.delegates.index{|x| x.xml_id.to_s == result.at_css('Delegate_id').text} if !result.at_css('Delegate_id').nil?
                vs.voting_results.create(:delegate_id => del_index.nil? ? nil : conference.delegates[del_index].id, 
                  :present => result.at_css('Present').nil? ? nil : result.at_css('Present').text, 
                  :vote => result.at_css('Vote').nil? ? nil : result.at_css('Vote').text, 
                  :weight => result.at_css('Weight').nil? ? nil : result.at_css('Weight').text
                )
              end
            end
          end

          # indicate the the file has been processed
          self.file_processed = true
          self.save
        end
      end
=begin
    # conference
    conf = doc.at_css('Conference')
    puts "------------ conf date = #{conf.at_css('StartDate').text[0..9]}"
    puts "------------ conf name = #{conf.at_css('name').text}"
    puts "------------ conf label = #{conf.at_css('conferenceLabel').text}"

    # groups
    doc.css('Group').each do |group|
      puts ""
      puts "------------ group id = #{group.at_css('id').text}"
      puts "------------ group text = #{group.at_css('Text').text}"
      puts "------------ group shortname = #{group.at_css('ShortName').text}"
    end

    # delegates
    doc.css('Delegate').each do |delegate|
      puts ""
      puts "------------ delegate id = #{delegate.at_css('id').text}"
      puts "------------ delegate group id = #{delegate.at_css('Group_id').text}" if delegate.at_css('Group_id')
      puts "------------ delegate firstname = #{delegate.at_css('firstname').text}"  if delegate.at_css('firstname')
      puts "------------ delegate title = #{delegate.at_css('title').text}" if delegate.at_css('title')
    end

    # agendas
    doc.css('Agenda').each do |agenda|
      puts ""
      puts "------------ agenda id = #{agenda.at_css('id').text}"
      puts "------------ agenda sort order = #{agenda.at_css('SortOrder').text}" if agenda.at_css('SortOrder')
      puts "------------ agenda level = #{agenda.at_css('Level').text}"  if agenda.at_css('Level')
      puts "------------ agenda name = #{agenda.at_css('Name').text}" if agenda.at_css('Name')
      puts "------------ agenda desc = #{agenda.at_css('Description').text}" if agenda.at_css('Description')
    end

    # voting session
    doc.css('VotingSession').each do |session|
      puts ""
      puts "------------ session id = #{session.at_css('id').text}"
      puts "------------ session agenda id = #{session.at_css('Agenda_id').text}" if session.at_css('Agenda_id')
      puts "------------ session passed = #{session.at_css('Passed').text}"  if session.at_css('Passed')
      puts "------------ session quorum = #{session.at_css('Quorum').text}" if session.at_css('Quorum')
      puts "------------ session results 1 = #{session.at_css('Result1').text}" if session.at_css('Result1')
      puts "------------ session results 3 = #{session.at_css('Result3').text}" if session.at_css('Result3')
      puts "------------ session results 5 = #{session.at_css('Result5').text}" if session.at_css('Result5')
      puts "------------ session results 1 text = #{session.at_css('Result1Text').text}" if session.at_css('Result1Text')
      puts "------------ session results 3 text = #{session.at_css('Result3Text').text}" if session.at_css('Result3Text')
      puts "------------ session results 5 text = #{session.at_css('Result5Text').text}" if session.at_css('Result5Text')
      puts "------------ session button 1 text = #{session.at_css('Button1Text').text}" if session.at_css('Button1Text')
      puts "------------ session button 3 text = #{session.at_css('Button3Text').text}" if session.at_css('Button3Text')
      puts "------------ session voting concl = #{session.at_css('VotingConclusion').text}" if session.at_css('VotingConclusion')
    end

    # voting result
    doc.css('VotingResult').each do |result|
      puts ""
      puts "------------ result voting session id = #{result.at_css('VotingSession_id').text}" if result.at_css('VotingSession_id')
      puts "------------ result delegate id = #{result.at_css('Delegate_id').text}"  if result.at_css('Delegate_id')
      puts "------------ result present = #{result.at_css('Present').text}" if result.at_css('Present')
      puts "------------ result vote = #{result.at_css('Vote').text}" if result.at_css('Vote')
      puts "------------ result weight = #{result.at_css('Weight').text}" if result.at_css('Weight')
    end

=end
      file.close
    end
  end
end
