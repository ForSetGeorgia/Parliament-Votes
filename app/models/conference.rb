class Conference < ActiveRecord::Base

  has_many :agendas, :dependent => :destroy
  has_many :groups, :dependent => :destroy
  has_many :delegates, :dependent => :destroy
  belongs_to :upload_file
  
  accepts_nested_attributes_for :agendas
  accepts_nested_attributes_for :groups
  accepts_nested_attributes_for :delegates

  attr_accessible :upload_file_id, :start_date, :name, :conference_label, :agendas_attributes, :groups_attributes

  
end
