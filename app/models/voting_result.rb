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
      when 3
        I18n.t('helpers.boolean.n')
      else
        if self.voting_session.agenda.parliament_id == 1
          I18n.t('helpers.links.not_present2')
        else
          I18n.t('helpers.links.not_present')
        end
    end
  end

  def self.by_session(voting_session_id)
    includes(:delegate => :group, :voting_session => :agenda).where(:voting_session_id => voting_session_id)
  end

  def self.not_deleted
    includes(:voting_session => {:agenda => {:conference => :upload_file}}).where("upload_files.is_deleted = 0")
  end

  # remove one of the records that have the same value for:
  # - voting_session_id, delegate_id, present, vote
  def self.remove_duplicates
    start = Time.now
    vrs = VotingResult.group('voting_session_id, delegate_id, present, vote').having('count(*) > 1').where(is_manual_add: true).map{|x| [x.voting_session_id, x.delegate_id]}
    if vrs.present?
      puts "found #{vrs.length} duplicate records"
      vrs.each do |vr|
        # delete 1 of the 2 records
        VotingResult.where(voting_session_id: vr[0], delegate_id: vr[1]).last.delete
      end

      puts "Took #{Time.now - start} seconds to delete duplicate records"

      Parliament.pluck(:id).each do |id|
        puts "- updating parliament #{id} vote counts"
        Agenda.update_law_vote_results(id)
        AllDelegate.update_vote_counts(id)
      end

      # clear out json api files
      FileUtils.rm_rf(AllDelegate::JSON_API_PATH)
    end

    puts "Took #{Time.now - start} seconds to finish everything"
  end

end
