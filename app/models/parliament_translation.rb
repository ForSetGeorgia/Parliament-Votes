class ParliamentTranslation < ActiveRecord::Base
	belongs_to :parliament

  attr_accessible :parliament_id, :name, :locale

  validates :name, :presence => true
  validates :name, :uniqueness => true

end
