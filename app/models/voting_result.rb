class VotingResult < ActiveRecord::Base
  
  belongs_to :voting_session
  belongs_to :delegate

  attr_accessible :voting_session_id, :delegate_id, :present, :vote, :weight

  def present_formatted
    if read_attribute(:present)
      I18n.t('helpers.boolean.y')
    else
      I18n.t('helpers.boolean.n')
    end
  end

  def vote_formatted
    case read_attribute(:vote)
      when 1
        I18n.t('helpers.boolean.y')
      else
        I18n.t('helpers.boolean.n')
    end
  end

end
