class Agenda < ActiveRecord::Base
  
  has_one :voting_session, :dependent => :destroy
  belongs_to :conference

  accepts_nested_attributes_for :voting_session

  attr_accessible :xml_id, :conference_id, :sort_order, :level, :name, :description, :voting_session_attributes

end
