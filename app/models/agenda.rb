class Agenda < ActiveRecord::Base
  
  has_many :voting_sessions, :dependent => :destroy
  belongs_to :conference

  accepts_nested_attributes_for :voting_sessions

  attr_accessible :id, :conference_id, :sort_order, :level, :name, :description, :voting_sessions_attributes

end
