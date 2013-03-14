class UploadFile < ActiveRecord::Base
  has_paper_trail
  
  has_one :conference, :dependent => :destroy
  belongs_to :parliament
  belongs_to :deleted_by, :class_name => "User", :foreign_key => "delete_by_id"

  accepts_nested_attributes_for :conference

	attr_accessible :xml, :xml_file_name, :xml_content_type, :xml_file_size, :xml_updated_at, 
      :conference_attributes, :file_processed, :number_possible_members, :parliament_id, 
      :is_deleted, :deleted_at, :deleted_by_id

  validates :xml_file_name, :number_possible_members, :parliament_id, :presence => true

	has_attached_file :xml, :url => "/system/upload_files/:id/:filename"

  scope :not_deleted, where(:is_deleted => false)
  scope :deleted, where(:is_deleted => true)
  
  validate :file_does_not_exist
  after_save :process_file

  def self.with_conference
    includes(:conference)
  end

  # if conference already on file with same date, throw error
  def file_does_not_exist
    doc = Nokogiri::XML(self.xml.queued_for_write[:original])
    conf = doc.at_css('Conference')
    if conf.present?
      already_exists = Conference.where(:start_date => conf.at_css('StartDate').text[0..9])

      if already_exists.present? && !self.id.present?
        errors.add(:xml, I18n.t('activerecord.messages.upload_file.already_exists', :file_name => self.xml_file_name))
      end
    end

  end

  # mark file as deleted
  def mark_as_deleted(current_user)
    self.is_deleted = true
    self.deleted_at = Time.now
    self.deleted_by_id = current_user.id
    self.save
  end

  # undelete the file
  def restore(current_user)
    self.is_deleted = false
    self.deleted_at = Time.now
    self.deleted_by_id = current_user.id
    self.save
  end

  # update the number members and parliament id in upload file and all its agendas
  def update_data(number_members, parliament_id)
    if number_members.present? && parliament_id.present?
      UploadFile.transaction do
        self.number_possible_members = number_members
        self.parliament_id = parliament_id
        self.save

        Agenda.where(:conference_id => self.conference.id)
          .update_all(:number_possible_members => number_members, :parliament_id => parliament_id)

      end
    end
  end

  def unprocess_file
    # voting session & voting results
    if self.conference.present?
      self.conference.agendas.each do |agenda|
        if agenda.voting_session
          agenda.voting_session.voting_results.delete_all
          agenda.voting_session.delete
        end
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
              :description => agenda.at_css('Description').nil? ? nil : agenda.at_css('Description').text,
              :number_possible_members => self.number_possible_members,
              :parliament_id => self.parliament_id
            )

            # add voting sessions for agenda          
            doc.xpath("//VotingSession/Agenda_id[contains(text(), '#{ag.xml_id}')]/..").each do |session|
              # sometimes quorum value is 1 sometimes it is the number of votes need for quorum
              quorum = false
              if session.at_css('Quorum') 
                if session.at_css('Quorum').text.length > 1 && session.at_css('Result5') && 
                    session.at_css('Quorum').text.to_i >= session.at_css('Result5').text.to_i
                  quorum = true
                else
                  quorum = session.at_css('Quorum').text.length
                end              
              end

              vs = ag.create_voting_session(:xml_id => session.at_css('id').text, 
#                :agenda_id => session.at_css('Agenda_id').nil? ? nil : session.at_css('Agenda_id').text, 
                :passed => session.at_css('Passed').nil? ? nil : session.at_css('Passed').text, 
                :quorum => quorum,
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

            # if the agenda is a law, update its status
            ag.check_is_law

            # if this is a law, look for new delegates
            AllDelegate.add_if_new(ag.conference.delegates) if ag.is_law
          end

          # update the conference with the number of laws and sessions
          conference.number_laws = conference.agendas.select{|x| x.is_law == true}.count
          conference.number_sessions = conference.agendas.count
          conference.save

        end
        # indicate the the file has been processed
        self.file_processed = true
        self.save
      end

      file.close
    end
  end
end
