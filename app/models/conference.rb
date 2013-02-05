class Conference < ActiveRecord::Base

  has_many :agendas, :dependent => :destroy

  accepts_nested_attributes_for :agendas

  attr_accessible :start_date, :name, :conference_label, :agendas_attributes

  
end
