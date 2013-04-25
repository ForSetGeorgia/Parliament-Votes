# encoding: UTF-8
class Agenda < ActiveRecord::Base
  has_paper_trail
  
  has_one :voting_session, :dependent => :destroy
  belongs_to :conference
  belongs_to :parliament
  belongs_to :session_number1, :class_name => 'Agenda', :foreign_key => 'session_number1_id'
  belongs_to :session_number2, :class_name => 'Agenda', :foreign_key => 'session_number2_id'

  accepts_nested_attributes_for :voting_session

  attr_accessible :xml_id, :conference_id, :sort_order, :level, :name, :description, :voting_session_attributes,
      :is_law, :registration_number, :session_number, :number_possible_members, :law_url, :law_id,
      :official_law_title, :law_description, :law_title, :parliament_id,
      :session_number1_id, :session_number2_id, :is_public, :made_public_at, :public_url_id

	attr_accessor :send_notification, :was_public

	validates :law_url, :format => {:with => URI::regexp(['http','https']), :message => I18n.t('activerecord.messages.agenda.invalid_url')},  :if => "!law_url.blank?"

  validates :number_possible_members, :parliament_id, :presence => true
  validate :can_be_public
	after_find :check_if_public
  after_save :update_records_for_public_law
  before_save :add_public_url_id

  scope :public, where(:is_public => true)
  scope :not_public, where(:is_public => false)

  DEFAULT_NUMBER_MEMBERS = 150
  MAKE_PUBLIC_PARAM = 'make_public'
  QUOTES = ['„', '“', '"']

	def check_if_public
		self.was_public = self.has_attribute?(:is_public) && self.is_public ? true : false
	end

  def self.public_laws
    not_deleted.final_laws.public.with_public_url_id
  end

  def self.with_public_url_id
    where("public_url_id is not null and public_url_id != ''")
  end

  # in order for a law to be public, the following must be true
  # - is law
  # - passed vote
  # - official law title exists
  # - law_url exists
  # - law_id exists
  # - session number in FINAL_VERSION
  # - session_number1_id and session_number2_id exist if III session
  def can_be_public
    if is_public && !was_public
      has_error = false
      if !is_law || !official_law_title.present? || !law_url.present? || !law_id.present?
        has_error = true
      elsif !(session_number.index(FINAL_VERSION[0]) || (session_number.index(FINAL_VERSION[1]) && session_number1_id.present? && session_number2_id.present?))
        has_error = true
      elsif !(self.voting_session.present? && self.voting_session.passed)
        has_error = true
      end

      if has_error
        errors.add(:is_public, I18n.t('activerecord.messages.agenda.cannot_be_public', 
                    :name => self.official_law_title.present? ? self.official_law_title : self.name))
      end
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

  # if the law just became public, create vote results for not attended people
  # and update vote counts for all delegates
  def update_records_for_public_law
    if !was_public && is_public && self.voting_session.present?
      delegates = AllDelegate.available_delegates(self.id)
      if delegates.present?
        delegates.each do |member|
          del = Delegate.create(:conference_id => self.conference_id, :xml_id => member.xml_id, 
            :group_id => member.group_id,
            :first_name => member.first_name)
          # now save voting result record
          VotingResult.create(:voting_session_id => self.voting_session.id, 
                    :delegate_id => del.id,
                    :present => false,
                    :is_manual_add => true)
        end
      end

      # update vote count
      AllDelegate.update_vote_count(self.parliament_id)
    end
  end

  def self.by_conference(conference_id)
    includes(:voting_session => :voting_results).where(:conference_id => conference_id)
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

  def self.final_laws
    laws_only(true)
    .includes(:voting_session)
    .where('voting_sessions.passed = 1 and agendas.session_number in (?)', ["#{FINAL_VERSION[0]} #{CONSISTENT_SESSION_NAME[0]}", "#{FINAL_VERSION[1]} #{CONSISTENT_SESSION_NAME[1]}"])
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
    self.voting_session.result1
  end

  def total_no
#    self.voting_session.voting_results.select{|x| x.vote == 3}.count
    self.voting_session.result3
  end

  def total_abstain
#    self.voting_session.voting_results.select{|x| x.vote == 0}.count
    self.voting_session.result0
  end

  def total_not_present
#    self.number_possible_members - total_yes - total_no - total_abstain
    self.voting_session.not_present
  end

  def is_final_version?
    x = false
    
    if self.session_number.present?
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
    found = false
    if self.voting_session
      PREFIX.each do |pre|
        if self.name.index(pre)
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
        self.registration_number = reg_num.to_s
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
    mod_desc = text.gsub(self.registration_number, '') if self.registration_number.present?
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
    remove << self.registration_number if self.registration_number.present?
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


  private

  PREFIX = ['ერთი', 'III', 'II', 'I']

  POSTFIX = ['მოსმენით', 'მოსმენა', 'მოსმ', 'მოს', 'მოს']

  CONSISTENT_SESSION_NAME = ['მოსმენით', 'მოსმენა']

  FINAL_VERSION = ['ერთი', 'III']
end
