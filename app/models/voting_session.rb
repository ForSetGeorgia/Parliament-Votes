class VotingSession < ActiveRecord::Base
  has_paper_trail

  has_many :voting_results, :dependent => :destroy
  belongs_to :agenda
  accepts_nested_attributes_for :voting_results

  ###########
  ## NOTE
  ## result1 = yes vote
  ## result3 = no vote
  ## result0 = abstain
  ###########

  attr_accessible :xml_id, :agenda_id, :passed, :quorum, 
      :result1, :result3, :result5, 
      :result1text, :result3text, :result5text, 
      :button1text, :button3text, :voting_conclusion,
      :voting_results_attributes, :result0, :not_present


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


  def update_results
    self.result1 = self.voting_results.select{|x| x.vote == 1}.count
    self.result3 = self.voting_results.select{|x| x.vote == 3}.count
    self.result0 = self.voting_results.select{|x| x.vote == 0}.count
    self.not_present = self.agenda.number_possible_members-self.result1-self.result3-self.result0
    self.save
  end
end
