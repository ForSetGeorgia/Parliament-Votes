# encoding: UTF-8
class Agenda < ActiveRecord::Base
  has_paper_trail
  
  has_one :voting_session, :dependent => :destroy
  belongs_to :conference

  accepts_nested_attributes_for :voting_session

  attr_accessible :xml_id, :conference_id, :sort_order, :level, :name, :description, :voting_session_attributes,
      :is_law, :registration_number, :session_number, :number_possible_members, :law_url

	validates :law_url, :format => {:with => URI::regexp(['http','https']), :message => I18n.t('activerecord.messages.agenda.invalid_url')},  :if => "!law_url.blank?"

  DEFAULT_NUMBER_MEMBERS = 150

  def self.by_conference(conference_id)
    includes(:voting_session).where(:conference_id => conference_id)
  end

  def self.laws_only(yes)
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

            # look for registration number in description
            # format: (07-3/32, 12.12.2012) || (07-2/5, 29.11.2012) ||  (07-2/3,05.11.2012)
            reg = /\(\d{2}-\d\/\d{1,2}, {0,5}\d{2}.\d{2}.\d{4}\)/
            reg_num = reg.match(self.description)
            if reg_num
              self.registration_number = reg_num.to_s
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


  private

  PREFIX = ['ერთი', 'III', 'II', 'I']

  POSTFIX = ['მოსმენით', 'მოსმენა', 'მოსმ.', 'მოს.']

  CONSISTENT_SESSION_NAME = ['მოსმენით', 'მოსმენა']

  FINAL_VERSION = ['ერთი', 'III']
end
