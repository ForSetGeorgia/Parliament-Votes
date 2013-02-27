class Group < ActiveRecord::Base
  has_paper_trail

  belongs_to :conference
  has_many :delegates, :dependent => :destroy

  attr_accessible :xml_id, :text, :short_name, :conference_id

  def self.by_conference(conference_id)
    where(:conference_id => conference_id).order("short_name asc")
  end
end
