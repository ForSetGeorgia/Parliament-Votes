class VotingResult < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :voting_session
  belongs_to :delegate

  attr_accessible :voting_session_id, :delegate_id, :present, :vote, :weight, :is_edited, :is_manual_add

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

  def self.by_session(voting_session_id)
    includes(:delegate => :group).where(:voting_session_id => voting_session_id)
  end
end
