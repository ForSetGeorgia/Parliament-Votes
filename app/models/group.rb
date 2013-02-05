class Group < ActiveRecord::Base

  has_many :delegates, :dependent => :destroy
  accepts_nested_attributes_for :delegates

  attr_accessible :id, :text, :short_name, :delegates_attributes
end
