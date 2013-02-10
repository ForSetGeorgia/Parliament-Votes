class Group < ActiveRecord::Base
  has_paper_trail

  belongs_to :conference
  has_many :delegates, :dependent => :destroy

  attr_accessible :xml_id, :text, :short_name, :conference_id
end
