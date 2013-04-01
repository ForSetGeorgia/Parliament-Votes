class Delegate < ActiveRecord::Base
  has_paper_trail

  has_many :voting_results, :dependent => :destroy
  belongs_to :all_delegate
  belongs_to :group
  belongs_to :conference

  attr_accessible :xml_id, :conference_id, :group_id, :first_name, :title, :all_delegate_id

end
