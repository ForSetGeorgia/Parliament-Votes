class VotingResult < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :voting_session
  belongs_to :delegate

  attr_accessible :voting_session_id, :delegate_id, :present, :vote, :weight, :is_edited, :is_manual_add

	attr_accessor :send_notification, :original_vote

  ABSTAIN = 0

	after_find :set_original_vote

	def set_original_vote
		self.original_vote = read_attribute(:vote)
	end

  def present_formatted
    if read_attribute(:present)
      I18n.t('helpers.boolean.y')
    else
      I18n.t('helpers.boolean.n')
    end
  end

  def vote_formatted
    case read_attribute(:vote)
      when 0
        I18n.t('helpers.boolean.abstain')
      when 1
        I18n.t('helpers.boolean.y')
      else
        I18n.t('helpers.boolean.n')
    end
  end

  def self.by_session(voting_session_id)
    includes(:delegate => :group, :voting_session => :agenda).where(:voting_session_id => voting_session_id)
  end

  def self.not_deleted
    includes(:voting_session => {:agenda => {:conference => :upload_file}}).where("upload_files.is_deleted = 0")
  end
end
