class Agenda < ActiveRecord::Base
  has_paper_trail
  
  has_one :voting_session, :dependent => :destroy
  belongs_to :conference

  accepts_nested_attributes_for :voting_session

  attr_accessible :xml_id, :conference_id, :sort_order, :level, :name, :description, :voting_session_attributes


  def self.by_conference(conference_id)
    includes(:voting_session).where(:conference_id => conference_id)

  end
end
