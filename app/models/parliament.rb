class Parliament < ActiveRecord::Base

  has_many :upload_files
  has_many :agendas

  attr_accessible :name, :start_date, :end_date, :id

  validates :name, :presence => true
  validates :name, :uniqueness => true
  scope :sorted_name, order("name desc")
end
