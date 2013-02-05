class VotingSession < ActiveRecord::Base

  has_many :voting_results, :dependent => :destroy
  belongs_to :agenda
  accepts_nested_attributes_for :voting_results

  attr_accessible :id, :agenda_id, :passed, :quorum, 
      :result1, :result3, :result5, 
      :result1text, :result3text, :result5text, 
      :button1text, :button3text, :voting_conclusion,
      :voting_results_attributes

end
