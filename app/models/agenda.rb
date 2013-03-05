# encoding: UTF-8
class Agenda < ActiveRecord::Base
  has_paper_trail
  
  has_one :voting_session, :dependent => :destroy
  belongs_to :conference

  accepts_nested_attributes_for :voting_session

  attr_accessible :xml_id, :conference_id, :sort_order, :level, :name, :description, :voting_session_attributes,
      :is_law, :registration_number, :session_number, :number_possible_members, :law_url, :law_id,
      :official_law_title, :law_description, :law_title

	validates :law_url, :format => {:with => URI::regexp(['http','https']), :message => I18n.t('activerecord.messages.agenda.invalid_url')},  :if => "!law_url.blank?"

  DEFAULT_NUMBER_MEMBERS = 150
  
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
    self.voting_session.voting_results.select{|x| x.vote == 1}.count
  end

  def total_no
    self.voting_session.voting_results.select{|x| x.vote == 3}.count
  end

  def total_not_present
    self.number_possible_members - total_yes - total_no
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

  # if agenda is a law, set is_law, reg #, and session #
  def check_is_law
    found = false
    if self.voting_session
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
    end
  end

  def generate_missing_data
    generate_registration_number if !self.registration_number.present?
    generate_official_law_title if !self.official_law_title.present?
    generate_law_description if !self.law_description.present?
    generate_law_title if !self.law_title.present?
  end

  # look for registration number in description
  # format: (07-3/32, 12.12.2012) || (07-2/5, 29.11.2012) ||  (07-2/3,05.11.2012)  || (#07-3/16. 22.11.2012)
  def generate_registration_number
    if self.description.present?
      reg = /\(\#{0,1}\d{2}-\d\/\d{1,2}(,||.) {0,5}\d{2}.\d{2}.\d{4}\)/
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
puts "using name field for text"
      text = self.name
    end
puts "text = #{text}"
    quotes = ['„', '“', '"']

    index1 = text.index(quotes[0])
    index1 = text.index(quotes[2]) if index1.nil?
    index1 = text.index(quotes[1]) if index1.nil?

    index2 = text.index(quotes[1], index1 ? index1+1 : 0)
    index2 = text.index(quotes[2], index1 ? index1+1 : 0) if index2.nil?
    index2 = text.index(quotes[0], index1 ? index1+1 : 0) if index2.nil?

    index3 = text.index(quotes[1], index2 ? index2+1 : 0)
    index3 = text.index(quotes[2], index2 ? index2+1 : 0) if index3.nil?
    index3 = text.index(quotes[0], index2 ? index2+1 : 0) if index3.nil?

    if index1 && index3
puts "index1 and index3"
      self.official_law_title = text[index1..index3-1]
    elsif index1 && index2
puts "index1 and index2"
      self.official_law_title = text[index1..index2]
    elsif !use_description_field 
puts "just using name"
      self.official_law_title = self.name
    else
puts "calling again"
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


  private

  PREFIX = ['ერთი', 'III', 'II', 'I']

  POSTFIX = ['მოსმენით', 'მოსმენა', 'მოსმ.', 'მოს.']

  CONSISTENT_SESSION_NAME = ['მოსმენით', 'მოსმენა']

  FINAL_VERSION = ['ერთი', 'III']
end
