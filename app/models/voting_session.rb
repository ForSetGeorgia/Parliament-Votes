class VotingSession < ActiveRecord::Base
  has_paper_trail

  has_many :voting_results, :dependent => :destroy
  belongs_to :agenda
  accepts_nested_attributes_for :voting_results

  attr_accessible :xml_id, :agenda_id, :passed, :quorum, 
      :result1, :result3, :result5, 
      :result1text, :result3text, :result5text, 
      :button1text, :button3text, :voting_conclusion,
      :voting_results_attributes


  def passed_formatted
    if read_attribute(:passed)
      I18n.t('helpers.boolean.y')
    else
      I18n.t('helpers.boolean.n')
    end
  end

  def quorum_formatted
    if read_attribute(:quorum)
      I18n.t('helpers.boolean.y')
    else
      I18n.t('helpers.boolean.n')
    end
  end
end
