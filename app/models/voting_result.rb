class VotingResult < ActiveRecord::Base
  
  belongs_to :voting_session
  belongs_to :delegate

  attr_accessible :voting_session_id, :delegate_id, :present, :vote, :weight

end
