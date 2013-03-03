# encoding: UTF-8
class Agenda < ActiveRecord::Base
  has_paper_trail
  
  has_one :voting_session, :dependent => :destroy
  belongs_to :conference

  accepts_nested_attributes_for :voting_session

  attr_accessible :xml_id, :conference_id, :sort_order, :level, :name, :description, :voting_session_attributes,
      :is_law, :registration_number, :session_number, :number_possible_members, :law_url, :law_id,
      :official_law_title, :law_description, :name2

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

            if self.description.present?
              # look for registration number in description
              # format: (07-3/32, 12.12.2012) || (07-2/5, 29.11.2012) ||  (07-2/3,05.11.2012)  || (#07-3/16. 22.11.2012)
              reg = /\(\d{2}-\d\/\d{1,2}, {0,5}\d{2}.\d{2}.\d{4}\)/
              reg_num = reg.match(self.description)
              if reg_num
                self.registration_number = reg_num.to_s
              end

              # official law title - in description " .... " .. "
              quotes = ['„', '“', '"']
              index1 = self.description.index(quotes[0])
              index1 = self.description.index(quotes[2]) if index1.nil?
              index1 = self.description.index(quotes[1]) if index1.nil?

              index2 = self.description.index(quotes[1], index1 ? index1+1 : 0)
              index2 = self.description.index(quotes[2], index1 ? index1+1 : 0) if index2.nil?
              index2 = self.description.index(quotes[0], index1 ? index1+1 : 0) if index2.nil?

              index3 = self.description.index(quotes[1], index2 ? index2+1 : 0)
              index3 = self.description.index(quotes[2], index2 ? index2+1 : 0) if index3.nil?
              index3 = self.description.index(quotes[0], index2 ? index2+1 : 0) if index3.nil?

              if index1 && index3
                self.official_law_title = self.description[index1..index3-1]
              elsif index1 && index2
                self.official_law_title = self.description[index1..index2]
              end

              # law description - text between () but not reg number
              mod_desc = self.description      
              mod_desc = self.description.gsub(self.registration_number, '') if self.registration_number.present?
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

              # name 2 - all text in description minus reg #, session # and law description
              remove = []
              remove << self.registration_number if self.registration_number.present?
              remove << "(#{self.law_description})" if self.law_description.present?
              remove << session

              text = self.description.dup
              remove.each do |x|
                text.gsub!(x, '')
              end
              self. name2 = text if text.present?
            end

            self.save
            found = true
            break
          end
          break if found
        end
      end
    end
  end

  def gen_law_title
    puts '--------------------'
    puts self.id
    puts self.description
    if self.description.present?
      mod_desc = self.description      
      mod_desc = self.description.gsub(self.registration_number, '') if self.registration_number.present?
      puts '---------'
      puts mod_desc
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

      puts "index1 = #{index1}; index2 = #{index2}"
      if index1 && index2
        puts '---'
        self.law_description = mod_desc[index1..index2]
        puts self.law_description
      end
    end
  end

  private

  PREFIX = ['ერთი', 'III', 'II', 'I']

  POSTFIX = ['მოსმენით', 'მოსმენა', 'მოსმ.', 'მოს.']

  CONSISTENT_SESSION_NAME = ['მოსმენით', 'მოსმენა']

  FINAL_VERSION = ['ერთი', 'III']
end
