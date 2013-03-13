class Parliament < ActiveRecord::Base

  attr_accessible :name, :start_date, :end_date, :id

  validates :name, :presence => true
  validates :name, :uniqueness => true
  scope :sorted_name, order("name desc")
end
