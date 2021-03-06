# encoding: UTF-8
class Agenda < ActiveRecord::Base
	require 'fileutils'
  require 'open-uri'
  has_paper_trail :ignore => [:impressions_count]
  is_impressionable :counter_cache => true
  
  has_one :voting_session, :dependent => :destroy
  belongs_to :conference
  belongs_to :parliament
  belongs_to :session_number1, :class_name => 'Agenda', :foreign_key => 'session_number1_id'
  belongs_to :session_number2, :class_name => 'Agenda', :foreign_key => 'session_number2_id'

  accepts_nested_attributes_for :voting_session

	has_attached_file :law_file, :url => "/system/law_files/:id/:filename"

  attr_accessible :xml_id, :conference_id, :sort_order, :level, :name, :description, :voting_session_attributes,
      :is_law, :registration_number, :registration_number_original, :session_number, :number_possible_members, :law_url, :law_id, :law_url_text,
      :official_law_title, :law_description, :law_title, :parliament_id,
      :session_number1_id, :session_number2_id, :is_public, :made_public_at, :public_url_id,
      :law_file, :law_file_file_name, :law_file_content_type, :law_file_file_size, :law_file_updated_at, :impressions_count

	attr_accessor :send_notification, :was_public, :law_url_original, :not_update_vote_count

	validates :law_url, :format => {:with => URI::regexp(['http','https']), :message => I18n.t('activerecord.messages.agenda.invalid_url')},  :if => "!law_url.blank?"

  validates :number_possible_members, :parliament_id, :presence => true
  validate :can_be_public
	after_find :set_original_values
  after_save :update_records_for_public_law
  before_save :add_public_url_id
  before_save :get_law_url_text

  scope :public, where(:is_public => true)
  scope :not_public, where(:is_public => false)

  DEFAULT_NUMBER_MEMBERS = 150
  MAKE_PUBLIC_PARAM = 'make_public'
  QUOTES = ['„', '“', '"']

	def set_original_values
		self.was_public = self.has_attribute?(:is_public) && self.is_public ? true : false
		self.law_url_original = self.has_attribute?(:law_url) && self.law_url ? self.law_url : nil
	end

  def self.public_laws
    not_deleted.final_laws.public.with_public_url_id
  end

  def self.with_public_url_id
    where("public_url_id is not null and public_url_id != ''")
  end

  def self.with_conference
    includes(:conference)
  end

  def self.laws_only(yes=false)
    if yes
      where(:is_law => 1)
    else
      where(:is_law => [0,1])
    end
  end

  def self.not_deleted
    joins(:conference => :upload_file).where("upload_files.is_deleted = 0")
  end

  # if this a law from the old system, session number will not exist
  def self.final_laws
    laws_only(true)
    .includes(:voting_session)
    .where('voting_sessions.passed = 1 and (agendas.session_number in (?) or agendas.parliament_id = 2)', ["#{FINAL_VERSION[0]} #{CONSISTENT_SESSION_NAME[0]}", "#{FINAL_VERSION[1]} #{CONSISTENT_SESSION_NAME[1]}"])
  end

  def self.with_parliament(ids=nil, start_date=nil, end_date=nil)
    x = includes(:conference, :parliament => :parliament_translations)
    if ids.present? && ids.class == Array
      x = x.where(:parliament_id => ids)      
    end
    if start_date.present?
      x = x.where('conferences.start_date >= ?', start_date)
    end
    if end_date.present?
      x = x.where('conferences.start_date <= ?', end_date)
    end
    return x
  end

  # in order for a law to be public, the following must be true
  # - is law
  # - passed vote
  # - official law title exists
  # - law_url exists ## 2014-03-17 turning this off since parliament.ge website no longer has text
  # - law_id exists
  # - session number in FINAL_VERSION
  # - session_number1_id and session_number2_id exist if III session
  def can_be_public
    if is_public && !was_public
      has_error = false
Rails.logger.debug "**************************"
#      if !is_law || !official_law_title.present? || !has_law_text? || !law_id.present?
      if !is_law || !official_law_title.present? || !law_id.present?
Rails.logger.debug "*********** - 1"
#Rails.logger.debug "****** is law = #{is_law}; title present = #{official_law_title.present?}; law text = #{has_law_text?}; law id = #{law_id.present?}"
Rails.logger.debug "****** is law = #{is_law}; title present = #{official_law_title.present?}; law id = #{law_id.present?}"
        has_error = true
      elsif parliament_id != 2 && !(session_number.index(FINAL_VERSION[0]) || (session_number.index(FINAL_VERSION[1]) && session_number1_id.present? && session_number2_id.present?))
Rails.logger.debug "*********** - 2"
        has_error = true
      elsif !(self.voting_session.present? && self.voting_session.passed)
Rails.logger.debug "*********** - 3"
        has_error = true
      end

      if has_error
        errors.add(:is_public, I18n.t('activerecord.messages.agenda.cannot_be_public', 
                    :name => self.official_law_title.present? ? self.official_law_title : self.name))
      end
    end
  end

  # law text can be string or file so check for both  
  def has_law_text?
    if law_url_text.present? || law_file_file_name.present?
      return true
    else
      return false
    end
  end

  # if the law is to become public, add public url id if it does not already exist
  def add_public_url_id
    if !was_public && is_public && !self.public_url_id.present? && self.voting_session.present?
      next_id = 1
      max_id = Agenda.maximum('public_url_id')
      
      next_id = max_id + 1 if max_id.present?

      self.public_url_id = next_id
    end
  end

  # if a law url was added/changed, get the text and save it
  def get_law_url_text
    if self.has_attribute?(:law_url_text) && self.law_url.present?
Rails.logger.debug "********** law url present"
      if self.law_url_original != self.law_url
Rails.logger.debug "********** law url different"
        self.law_url_text = '' #reset value
        doc = Nokogiri::HTML(open(self.law_url))
        t = doc.css('table')
        t.each do |table|
Rails.logger.debug "********** adding text"
          self.law_url_text << table.to_s.force_encoding("UTF-8")
        end
      end
    else
Rails.logger.debug "********** law url not present"
      # no url, so reset text
      self.law_url_text = nil if self.law_url_original.present?
    end
  end

  # if the law just became public, create vote results for not attended people
  # and update vote counts for all delegates
  def update_records_for_public_law(force_update=false)
    Rails.logger.debug "*********************************************"
    Rails.logger.debug "********** update for public law start"
    Rails.logger.debug "*********************************************"
    if (!was_public || force_update) && is_public && self.voting_session.present?
      delegates = AllDelegate.available_delegates(self.id)
      if delegates.present?
        del_count = 0
        vr_count = 0
        Rails.logger.debug "*********************************************"
        Rails.logger.debug "*********************************************"
        Rails.logger.debug "*********************************************"
        Rails.logger.debug "********** - there are #{delegates.length} delegates available"
        Rails.logger.debug "*********************************************"
        Rails.logger.debug "*********************************************"
        Rails.logger.debug "*********************************************"
        delegates.each do |member|
          # see if delegate record already exists
          d = Delegate.where(:conference_id => self.conference_id, :all_delegate_id => member.id)
          del = nil
          if d.present?
            del = d.first
          else
            Rails.logger.debug "*********************************************"
            Rails.logger.debug "********** -- creating delegate record for conf #{self.conference_id}; all del #{member.id}; xml id #{member.xml_id}"
            Rails.logger.debug "*********************************************"

            del = Delegate.create(:conference_id => self.conference_id, :xml_id => member.xml_id, 
              :group_id => member.group_id,
              :first_name => member.first_name_ka,
              :all_delegate_id => member.id)
            del_count += 1
          end

          # now save voting result record
          if del.present?
            Rails.logger.debug "*********************************************"
            Rails.logger.debug "********** -- creating voting result record for voting session #{self.voting_session.id}; del #{del.id}"
            Rails.logger.debug "*********************************************"

            VotingResult.create(:voting_session_id => self.voting_session.id, 
                      :delegate_id => del.id,
                      :present => false,
                      :is_manual_add => true)
            vr_count += 1
          end
        end
        Rails.logger.debug "*********************************************"
        Rails.logger.debug "*********************************************"
        Rails.logger.debug "*********************************************"
        Rails.logger.debug "********** for #{delegates.length}, created #{del_count} delegate records; added #{vr_count} voting result records"
        Rails.logger.debug "*********************************************"
        Rails.logger.debug "*********************************************"
        Rails.logger.debug "*********************************************"
      end

      # if this law has an assigned session1 and session2, add missing delegate records to those too
      sessions = [self.session_number1_id, self.session_number2_id]
      sessions.each do |session|
        del_count = 0
        vr_count = 0
        if session.present?
          Rails.logger.debug "*********************************************"
          Rails.logger.debug "*********************************************"
          Rails.logger.debug "*********************************************"
          Rails.logger.debug "********** adding missing delegates for session #{session}"
          Rails.logger.debug "*********************************************"
          Rails.logger.debug "*********************************************"
          Rails.logger.debug "*********************************************"
          attached_session = Agenda.find_by_id(session)
          if attached_session.present?
            delegates = AllDelegate.available_delegates(attached_session.id)
            if delegates.present?
              Rails.logger.debug "*********************************************"
              Rails.logger.debug "*********************************************"
              Rails.logger.debug "*********************************************"
              Rails.logger.debug "********** - there are #{delegates.length} delegates available"
              Rails.logger.debug "*********************************************"
              Rails.logger.debug "*********************************************"
              Rails.logger.debug "*********************************************"
              delegates.each do |member|
                # see if delegate record already exists
                d = Delegate.where(:conference_id => attached_session.conference_id, :all_delegate_id => member.id)
                del = nil
                if d.present?
                  del = d.first
                else
                  del = Delegate.create(:conference_id => attached_session.conference_id, :xml_id => member.xml_id, 
                    :group_id => member.group_id,
                    :first_name => member.first_name_ka,
                    :all_delegate_id => member.id)

                  del_count += 1
                end

                # now save voting result record
                if del.present?
                  VotingResult.create(:voting_session_id => attached_session.voting_session.id, 
                            :delegate_id => del.id,
                            :present => false,
                            :is_manual_add => true)
                  vr_count += 1
                end
              end
            end
          end
          Rails.logger.debug "*********************************************"
          Rails.logger.debug "*********************************************"
          Rails.logger.debug "*********************************************"
          Rails.logger.debug "********** for #{delegates.length}, created #{del_count} delegate records; added #{vr_count} voting result records"
          Rails.logger.debug "*********************************************"
          Rails.logger.debug "*********************************************"
          Rails.logger.debug "*********************************************"
        end
      end

      Rails.logger.debug "*********************************************"
      Rails.logger.debug "********** updating delegate vote counts"
      Rails.logger.debug "*********************************************"
      # update vote count
      AllDelegate.update_vote_counts(self.parliament_id) if !self.not_update_vote_count
      
      # clear out json api files
      FileUtils.rm_rf(AllDelegate::JSON_API_PATH)
    elsif was_public && !is_public && self.voting_session.present?
      # law is no longer public - update vote counts
      AllDelegate.update_vote_counts(self.parliament_id) if !self.not_update_vote_count

      # clear out json api files
      FileUtils.rm_rf(AllDelegate::JSON_API_PATH)
    end
    Rails.logger.debug "*********************************************"
    Rails.logger.debug "********** update for public law end"
    Rails.logger.debug "*********************************************"
  end

  def self.by_conference(conference_id)
    includes(:voting_session => :voting_results).where(:conference_id => conference_id)
  end

  def self.passed_laws_by_session(session_number, agenda_id)
    used_ids = claimed_session_ids(session_number)
    a = Agenda.includes(:conference).not_deleted.find_by_id(agenda_id)
    q = 'voting_sessions.passed = 1 and agendas.session_number = ? and conferences.start_date <= ? '
    full_query = [q]
    full_query << session_number

    if a.present?
      # must have happened before this law
      full_query << a.conference.start_date

      if used_ids.present?
        full_query << used_ids
        q << 'and agendas.id not in (?) '
      end

      x = laws_only(true).not_deleted
          .includes(:voting_session, :conference)
          .where(full_query)
    end

    return x
  end

  def self.passed_laws_by_session_matching(session_number, agenda_id)
    used_ids = claimed_session_ids(session_number)
    a = Agenda.includes(:conference).not_deleted.find_by_id(agenda_id)
    q = 'voting_sessions.passed = 1 and agendas.session_number = ? and conferences.start_date <= ? '
    full_query = [q]
    full_query << session_number

    if a.present?
      # must have happened before this law
      full_query << a.conference.start_date

      # use registration number and/or official law title to find match
      if a.registration_number.present? && a.official_law_title.present?
        full_query << a.registration_number
        full_query << "%#{a.official_law_title.gsub(QUOTES[0], '').gsub(QUOTES[1], '').gsub(QUOTES[2], '')}%"
        q << 'and (agendas.registration_number = ? or agendas.official_law_title like ?) '
      elsif a.registration_number.present?
        full_query << a.registration_number
        q << 'and agendas.registration_number = ? '
      elsif a.official_law_title.present?
        full_query << "%#{a.official_law_title.gsub(QUOTES[0], '').gsub(QUOTES[1], '').gsub(QUOTES[2], '')}%"
        q << 'and agendas.official_law_title like ? '
      else
        # no reg number or official title
        # - defualt to name
        full_query << "%#{a.name.gsub(QUOTES[0], '').gsub(QUOTES[1], '').gsub(QUOTES[2], '')}%"
        q << 'and agendas.name like ? '
      end


      if used_ids.present?
        full_query << used_ids
        q << 'and agendas.id not in (?) '
      end

      x = laws_only(true).not_deleted
          .includes(:voting_session, :conference)
          .where(full_query)
    end

    return x

  end

  def self.claimed_session_ids(session_number)
    field = nil
    ids = nil
    if session_number.index(PREFIX[2])
      field = 'session_number2_id'
    elsif session_number.index(PREFIX[3])
      field = 'session_number1_id'
    end

    if field
      x = select(field).laws_only(true).not_deleted
      ids = x.select{|x| x["#{field}"] != nil}.map{|x| x["#{field}"]}.uniq
    end

    return ids
  end

  # get the last number of members from the db.
  # - if on exists, use default
  def self.default_number_possible_members
    x = DEFAULT_NUMBER_MEMBERS 
    y = select('number_possible_members').order('created_at desc').limit(1).first
    if y
      x = y.number_possible_members
    end
    return x
  end

  def total_yes
#    self.voting_session.voting_results.select{|x| x.vote == 1}.count
    self.voting_session.result1 if self.voting_session
  end

  def total_no
#    self.voting_session.voting_results.select{|x| x.vote == 3}.count
    self.voting_session.result3 if self.voting_session
  end

  def total_abstain
#    self.voting_session.voting_results.select{|x| x.vote == 0}.count
    self.voting_session.result0 if self.voting_session
  end

  def total_not_present
#    self.number_possible_members - total_yes - total_no - total_abstain
    self.voting_session.not_present if self.voting_session
  end

  def is_final_version?
    x = false
    if self.parliament_id == 2
      x = true
    elsif self.session_number.present?
      FINAL_VERSION.each do |final|
        if self.session_number.index(final)
          x = true
          break
        end
      end
    end

    return x
  end

  # see if record is ერთი მოსმენით
  def is_by_one_session?
    x = false
    x = true if self.session_number.present? && self.session_number.index(FINAL_VERSION[0]).present? 
    return x
  end

  # does record have data before the 3 sessions were being recorded
  # parl id of 2 = 7th session
  # 3 sessions were not recorded until after 7th session
  def prior_to_all_session_data?
    x = false
    x = true if self.parliament_id.present? && self.parliament_id == 2
    return x
  end

  # if agenda is a law, set is_law, reg #, and session #
  def check_is_law
Rails.logger.debug "-----------------------"        
Rails.logger.debug "check is law"        
Rails.logger.debug "-----------------------"        
    found = false
    if self.voting_session
      PREFIX.each do |pre|
        if self.name.index(pre)
Rails.logger.debug "-----------------------"        
Rails.logger.debug "- this is a law!"        
Rails.logger.debug "-----------------------"        
          # found match
          self.is_law = true

          # add the correct complete postfix so there is consistency
          if pre == PREFIX[0]
            self.session_number = "#{pre} #{CONSISTENT_SESSION_NAME[0]}"
          else
            self.session_number = "#{pre} #{CONSISTENT_SESSION_NAME[1]}"
          end  

          generate_missing_data

          self.save
          found = true
          break
        end
        break if found
      end

=begin code to check prefix and postfix
      PREFIX.each do |pre|
        POSTFIX.each do |post|
          session = "#{pre} #{post}"
          if self.name.index(session)
            # found match
            self.is_law = true

            # add the correct complete postfix so there is consistency
            if pre == PREFIX[0]
              self.session_number = "#{pre} #{CONSISTENT_SESSION_NAME[0]}"
            else
              self.session_number = "#{pre} #{CONSISTENT_SESSION_NAME[1]}"
            end  

            generate_missing_data

            self.save
            found = true
            break
          end
          break if found
        end
      end
=end
    end
Rails.logger.debug "-----------------------"        
Rails.logger.debug "check is law DONE"        
Rails.logger.debug "-----------------------"        
  end

  def generate_missing_data
    generate_registration_number if !self.registration_number.present?
    generate_official_law_title if !self.official_law_title.present?
    generate_law_description if !self.law_description.present?
    generate_law_title if !self.law_title.present?
  end

  # look for registration number in description
  # format: (07-3/32, 12.12.2012) || (07-2/5, 29.11.2012) ||  
  #         (07-2/3,05.11.2012)  || (#07-3/16. 22.11.2012) || (N07-2/38;08.02.2013)
  def generate_registration_number
    if self.description.present?
      reg = /\((\#||N){0,1}\d{2}-\d\/\d{1,2}(,||.||;) {0,5}\d{2}.\d{2}.\d{4}\)/
      reg_num = reg.match(self.description)
      if reg_num
        self.registration_number_original = reg_num.to_s
        # convert to same format: 07-3/32, 12.12.2012 
        self.registration_number = reg_num.to_s.gsub(/[\(N\#\)]/, '').gsub(/\.\s/, ', ').gsub(';', ', ').gsub(/,\d/,', ')
      end
    end
  end

  # official law title - in description " .... " .. "
  # - keep first and second quote and text before last one
  # - text is not consitent on which quote is where so check for each quote type if the first is not founds
  def generate_official_law_title(use_description_field = true)
    text = self.description
    if !use_description_field || !text.present?
      text = self.name
    end

    index1 = text.index(QUOTES[0])
    index1 = text.index(QUOTES[2]) if index1.nil?
    index1 = text.index(QUOTES[1]) if index1.nil?

    index2 = text.index(QUOTES[1], index1 ? index1+1 : 0)
    index2 = text.index(QUOTES[2], index1 ? index1+1 : 0) if index2.nil?
    index2 = text.index(QUOTES[0], index1 ? index1+1 : 0) if index2.nil?

    index3 = text.index(QUOTES[1], index2 ? index2+1 : 0)
    index3 = text.index(QUOTES[2], index2 ? index2+1 : 0) if index3.nil?
    index3 = text.index(QUOTES[0], index2 ? index2+1 : 0) if index3.nil?

    if index1 && index3
      self.official_law_title = text[index1..index3-1]
    elsif index1 && index2
      self.official_law_title = text[index1..index2]
    elsif !use_description_field 
      self.official_law_title = self.name
    else
      # repeat process using name field
      generate_official_law_title(false)
    end

  end

  # law description - text between () but not reg number
  def generate_law_description
    text = self.description
    text = self.name if !text.present?

    mod_desc = text.dup
    mod_desc = text.gsub(self.registration_number_original, '') if self.registration_number_original.present?
    index1 = mod_desc.index('(')
    index2 = mod_desc.index(')', index1 ? index1+1 : 0)
    # if index2 is not at the end of the string, check if there is another one after this
    if index2 && index2 < mod_desc.length-1
      index3 = index2        
      index4 = index2
      until index3.nil?
        index3 = mod_desc.index(')', index3+1)
        index4 = index3 if index3
      end

      index2 = index4        
    end

    if index1 && index2
      self.law_description = mod_desc[index1..index2]
    end
  end

  # full name (law title) - all text in description minus reg #, session # and law description
  def generate_law_title
    text = self.description.dup
    text = self.name.dup if !text.present?

    remove = []
    remove << self.registration_number_original if self.registration_number_original.present?
    remove << self.law_description if self.law_description.present?
    remove << PREFIX
    remove << POSTFIX      

    remove.flatten.each do |x|
      text.gsub!(x, '')
    end
    if text.present?
      self.law_title = text if text.present?
    else
      self.law_title = self.name
    end
  end

  def self.session_list
    x = []
    PREFIX[1..PREFIX.length-1].reverse.each do |p|
      x << "#{p} #{CONSISTENT_SESSION_NAME[1]}"
    end
    x << "#{FINAL_VERSION[0]} #{CONSISTENT_SESSION_NAME[0]}"
    
    return x
  end


  # reprocess all laws to see if registration number can be found
  # - the regexp to find the reg # changes often and this will help find
  #   ones that were missed in the past
  def self.reprocess_registration_number
    count = 0
    Agenda.transaction do
      Agenda.laws_only(true).where(:registration_number => nil).each do |agenda|
        agenda.generate_registration_number
        if agenda.registration_number.present?
          puts "found new registration number #{agenda.registration_number}"
          agenda.save
          count += 1
        end
      end
    end
    puts "**************** added #{count} registration numbers"
  end

  # reprocess all records that are not marked as laws to see if any have been skipped
  def self.reprocess_items_not_laws
    count = 0
    Agenda.transaction do
      Agenda.where(:is_law => 0).each_with_index do |agenda, index|
        puts "index = #{index}" if index%50 == 0
        agenda.check_is_law # this method does the saving
        count += 1 if agenda.is_law
      end
    end
    puts "**************** marked #{count} as laws"
  end


  # update the vote counts for every public law in the parliament group
  def self.update_law_vote_results(parliament_id)
    Agenda.transaction do
      Agenda.where(:is_public => true, :parliament_id => parliament_id).each do |a|
        a.voting_session.update_results
      end
    end
  end

  private

  PREFIX = ['ერთი', 'III', 'II', 'I']

  POSTFIX = ['მოსმენით', 'მოსმენა', 'მოსმ', 'მოს', 'მოს']

  CONSISTENT_SESSION_NAME = ['მოსმენით', 'მოსმენა']

  FINAL_VERSION = ['ერთი', 'III']
end
