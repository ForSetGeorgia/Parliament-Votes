class Conference < ActiveRecord::Base

  has_many :agendas, :dependent => :destroy
  belongs_to :upload_file
  
  accepts_nested_attributes_for :agendas

  attr_accessible :upload_file_id, :start_date, :name, :conference_label, :agendas_attributes

  
end
