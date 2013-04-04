class AllDelegate < ActiveRecord::Base
  has_paper_trail

  has_many :delegates
  attr_accessible :xml_id, :group_id, :first_name, :title, :vote_count, :parliament_id


  # get the delegates that were not present
  def self.available_delegates(agenda_id)
    # get all delegates in the conference
    agenda = Agenda.find_by_id(agenda_id)
    used_delegates = Delegate.joins(:voting_results => :voting_session).select("distinct delegates.xml_id").where("voting_sessions.agenda_id = ?", agenda_id)
    if agenda.present?
      if used_delegates.present?
        AllDelegate.where("parliament_id = ? and xml_id not in (?)", agenda.parliament_id, used_delegates.map{|x| x.xml_id}).order("first_name")
      else
        AllDelegate.where("parliament_id = ?", agenda.parliament_id).order("first_name")
      end
    end
  end

  def self.add_if_new(delegates, parliament_id)
    if delegates.present?
      delegates.each do |delegate|
        exists = AllDelegate.where(:xml_id => delegate.xml_id, :first_name => delegate.first_name, :parliament_id => parliament_id)

        if !exists.present?
          AllDelegate.create(:xml_id => delegate.xml_id, :first_name => delegate.first_name, :parliament_id => parliament_id)
        end
      end
    end
  end

  def self.update_vote_count(parliament_id)
    x = passed_laws_vote_count(parliament_id)
    update(x.map{|x| x.id}, x.map{|x| {"vote_count" => x.vote_count}}) 
  end

  def self.passed_laws_vote_count(parliament_id)
    sql = "select ad.id, ad.first_name, count(*) as vote_count "
    sql << "from all_delegates as ad "
    sql << "inner join delegates as d on d.all_delegate_id = ad.id "
    sql << "inner join conferences as c on c.id = d.conference_id "
    sql << "inner join agendas as a on a.conference_id = c.id "
    sql << "inner join voting_sessions as vs on vs.agenda_id = a.id "
    sql << "inner join voting_results as vr on vr.voting_session_id = vs.id and vr.delegate_id = d.id "
    sql << "inner join upload_files as uf on uf.id = c.upload_file_id "
    sql << "where a.is_law = 1 and vs.passed = 1 and a.session_number in (:session_number) and uf.is_deleted = 0 "
    sql << "and ad.parliament_id = :parl_id "
    sql << "group by ad.id, ad.first_name"
    find_by_sql([sql, :session_number => ["#{Agenda::FINAL_VERSION[0]} #{Agenda::CONSISTENT_SESSION_NAME[0]}", "#{Agenda::FINAL_VERSION[1]} #{Agenda::CONSISTENT_SESSION_NAME[1]}"], :parl_id => parliament_id])
  end

  def self.passed_laws_voting_history(name)
    if name.present?
      Agenda.joins(:conference => :delegates, :voting_session => :voting_results)
        .not_deleted.final_laws
        .where('delegates.id = voting_results.delegate_id and delegates.first_name = ?', name)
    end
  end
end
