class Delegate < ActiveRecord::Base

  has_many :voting_results, :dependent => :destroy
  belongs_to :group

  attr_accessible :id, :group_id, :first_name, :title

end
