class AllDelegate < ActiveRecord::Base
  has_paper_trail
  is_impressionable :counter_cache => true

  has_many :delegates
  belongs_to :parliament

  attr_accessible :xml_id, :group_id, :first_name, :title, :parliament_id, :impressions_count,
    :vote_count, :yes_count, :no_count, :abstain_count, :absent_count, :started_at, :ended_at

  attr_accessor :session3_present, :session3_vote, :session2_present, :session2_vote, :session1_present, :session1_vote,
                :started_at_orig, :ended_at_orig, :checked_dates
                
	after_find :populate_dates
#  after_update :check_for_date_changes

  JSON_API_PATH = "#{Rails.root}/public/system/json/api"
  JSON_API_MEMBER_VOTES_PATH = "#{JSON_API_PATH}/v1/member_votes"
  JSON_API_ALL_MEMBER_VOTES_PATH = "#{JSON_API_PATH}/v1/all_member_votes"

	# record the original date values
	def populate_dates
		self.started_at_orig = self.has_attribute?(:started_at) ? self.started_at : nil
		self.ended_at_orig = self.has_attribute?(:ended_at) ? self.ended_at : nil
		self.checked_dates = false
	end

  # if the start/end dates changed, update the vote records to reflect these new dates
  def check_for_date_changes
    puts "**********************************"
    puts "** CHECKING FOR DATE CHANGES IN DELEGATE"
    puts "**********************************"
    update_vote_count = false

    
    # check if started at date added
    if self.started_at != self.started_at_orig
      puts "********** - started at changed"
      if self.started_at.present?
        puts "********** - started at has a value, deleting vote records before this date"
        delete_vote_records_outside_of_date(self.started_at, '<')
      end
      update_vote_count = true
    end
    
    # check if ended at date added
    if self.ended_at != self.ended_at_orig
      puts "********** - ended at changed"
      if self.ended_at.present?
        puts "********** - ended at has a value, deleting vote records after this date"
        delete_vote_records_outside_of_date(self.ended_at, '>')
      end
      update_vote_count = true
    end
    
    # if dates changed, update vote counts and clear api files
    if update_vote_count
      # update the vote counts for every law in this parliament
      puts "********** updating law vote counts"
      Agenda.update_law_vote_results(self.parliament_id)

      # now update vote counts of all delegates
      puts "********** updating delegate vote counts"
      AllDelegate.update_vote_counts(self.parliament_id, self.id)

      # clear out json api files
      FileUtils.rm_rf(AllDelegate::JSON_API_PATH)
    end

    puts "**********************************"
    puts "** DONE CHECKING FOR DATE CHANGES IN DELEGATE"
    puts "**********************************"
    return nil
  end


  # delete all vote records for this delegate that occur before or after a date
  # - date - date to compare against
  # - sign - > or <; if want to delete vote records before the date, use <; else >
  def delete_vote_records_outside_of_date(date, sign)
    if date.present? && sign.present?
      if ['>', '<'].index(sign).present?
        puts "**********************************"
        puts "** deleting vote records for = #{self.id} in parl #{self.parliament_id}; #{sign} #{date} **"
        puts "**********************************"
      
        AllDelegate.transaction do
          # get list of all conference ids that occur before the date
          conf_ids = Conference.select('conferences.id').joins(:agendas)
                      .where(["conferences.start_date #{sign} ? and agendas.parliament_id = ?", date, self.parliament_id]).map{|x| x.id}.uniq.sort
                
          if conf_ids.present?
            puts "********** found #{conf_ids.length} conference ids"
            # get all delegate records for this person
            del_ids = Delegate.select('id').where(:all_delegate_id => self.id, :conference_id => conf_ids)
            puts "********** found #{del_ids.length} delegate ids"

            if del_ids.present?
              puts "********** deleting voting results"
              VotingResult.where(:delegate_id => del_ids.map{|x| x.id}).delete_all
              puts "********** deleting delegate records"
              Delegate.where(:id => del_ids.map{|x| x.id}).delete_all
            end
          end          
        end
      end
    end
  end
  


  def self.sorted
    order('first_name')
  end
  
  def self.with_parliament(ids)
    x = nil
    if ids.present? && ids.class == Array
      x = x.where(:parliament_id => ids)      
    end
    
    return x
  end

  def self.with_parliament(ids=nil)
    x = includes(:parliament => :parliament_translations)
    if ids.present? && ids.class == Array
      x = x.where(:parliament_id => ids)      
    end
    return x
  end

  def session3_present_formatted
    if read_attribute(:session3_present).present?
      if read_attribute(:session3_present)
        I18n.t('helpers.boolean.y')
      else
        I18n.t('helpers.boolean.n')
      end
    end
  end

  def session3_vote_formatted
    case read_attribute(:session3_vote)
      when 0
        I18n.t('helpers.boolean.abstain')
      when 1
        I18n.t('helpers.boolean.y')
      when 3
        I18n.t('helpers.boolean.n')
      else
        if read_attribute(:parliament_id) == 1
          I18n.t('helpers.links.not_present2')
        else
          I18n.t('helpers.links.not_present')
        end
    end
  end

  def session2_present_formatted
    if read_attribute(:session2_present).present?
      if read_attribute(:session2_present)
        I18n.t('helpers.boolean.y')
      else
        I18n.t('helpers.boolean.n')
      end
    end
  end

  def session2_vote_formatted
    case read_attribute(:session2_vote)
      when 0
        I18n.t('helpers.boolean.abstain')
      when 1
        I18n.t('helpers.boolean.y')
      when 3
        I18n.t('helpers.boolean.n')
      else
        if read_attribute(:parliament_id) == 1
          I18n.t('helpers.links.not_present2')
        else
          I18n.t('helpers.links.not_present')
        end
    end
  end

  def session1_present_formatted
    if read_attribute(:session1_present).present?
      if read_attribute(:session1_present)
        I18n.t('helpers.boolean.y')
      else
        I18n.t('helpers.boolean.n')
      end
    end
  end

  def session1_vote_formatted
    case read_attribute(:session1_vote)
      when 0
        I18n.t('helpers.boolean.abstain')
      when 1
        I18n.t('helpers.boolean.y')
      when 3
        I18n.t('helpers.boolean.n')
      else
        if read_attribute(:parliament_id) == 1
          I18n.t('helpers.links.not_present2')
        else
          I18n.t('helpers.links.not_present')
        end
    end
  end

  # get the delegates that were not present
  def self.available_delegates(agenda_id)
    x = nil
    # get all delegates in the conference
    agenda = Agenda.with_conference.find_by_id(agenda_id)
    if agenda.present?
      date = agenda.conference.start_date
      used_delegates = Delegate.joins(:voting_results => :voting_session).select("distinct delegates.xml_id").where("voting_sessions.agenda_id = ?", agenda_id)
      if used_delegates.present?
        x = AllDelegate.where("parliament_id = ? and xml_id not in (?)", agenda.parliament_id, used_delegates.map{|x| x.xml_id}).order("first_name")
      else
        x = AllDelegate.where("parliament_id = ?", agenda.parliament_id).order("first_name")
      end
      if date.present?
        x = x.where(["(started_at is null or started_at <= :date) and (ended_at is null or ended_at >= :date) ", :date => date])
      end
    end
    return x
  end

  def self.add_if_new(delegates, parliament_id, started_at = Time.now)
    Rails.logger.debug "***************************"        
    Rails.logger.debug "adding new delegates if necessary"        
    Rails.logger.debug "***************************"        
    if delegates.present?
      delegates.each do |delegate|
        if delegate.present?
          exists = AllDelegate.where(:xml_id => delegate.xml_id, :first_name => delegate.first_name, :parliament_id => parliament_id)

          if exists.blank?
            Rails.logger.debug "***************************"        
            Rails.logger.debug " - adding delegate: #{delegate.inspect}; conf start date = #{started_at}"        
            Rails.logger.debug "***************************"        
            ad = AllDelegate.create(:xml_id => delegate.xml_id, :first_name => delegate.first_name, :parliament_id => parliament_id, :started_at => started_at)
            # now add id to delegate record
            if ad.present?
              delegate.all_delegate_id = ad.id
              delegate.save
            end
          end
        end
      end
    end
  end

  def self.passed_laws_voting_history(xml_id, start_date=nil, end_date=nil)
    x = nil
    if xml_id.present?
      x = Agenda.includes(:conference => :delegates, :voting_session => :voting_results)
        .public_laws
        .where('delegates.id = voting_results.delegate_id and delegates.xml_id = ?', xml_id)

      if start_date.present?
        x = x.where('conferences.start_date >= ?', start_date)
      end
      if end_date.present?
        x = x.where('conferences.start_date <= ?', end_date)
      end
    end

    return x
  end

  def self.votes_for_passed_law(agenda_public_url_id, get_all_3_sessions="true", search=nil, sort_col=nil, sort_dir=nil, limit=nil, offset=nil)
    x = []
    a = Agenda.includes(:conference).public_laws.find_by_public_url_id(agenda_public_url_id)

    if a.present?
      # get list of unique all delegate ids that have voting results
      # - only want to get votes for these people
      ids = [a.id]
      if get_all_3_sessions == "true"
        ids << a.session_number2_id
        ids << a.session_number1_id
      end
            
      all_ids = Delegate.select('delegates.all_delegate_id')
            .joins(:voting_results => :voting_session)
            .where('voting_sessions.agenda_id in (?)', ids)
            .map{|x| x.all_delegate_id}.uniq      

      sql = "select ad.id, ad.first_name, ad.parliament_id, s3.present as session3_present, s3.vote as session3_vote " 
      if get_all_3_sessions == "true"
        sql << ", s2.present as session2_present, s2.vote as session2_vote, s1.present as session1_present, s1.vote as session1_vote "
      end
      sql << "from all_delegates as ad "
      sql << "left join  (select d.all_delegate_id, vr.present, vr.vote from delegates as d inner join voting_results as vr on vr.delegate_id = d.id inner join voting_sessions as vs on vs.id = vr.voting_session_id where vs.agenda_id = :session3_id "
      sql << ") as s3 on s3.all_delegate_id = ad.id "
      if get_all_3_sessions == "true"
        sql << "left join  (select d.all_delegate_id, vr.present, vr.vote from delegates as d inner join voting_results as vr on vr.delegate_id = d.id inner join voting_sessions as vs on vs.id = vr.voting_session_id where vs.agenda_id = :session2_id "
        sql << ") as s2 on s2.all_delegate_id = ad.id "
        sql << "left join  (select d.all_delegate_id, vr.present, vr.vote from delegates as d inner join voting_results as vr on vr.delegate_id = d.id inner join voting_sessions as vs on vs.id = vr.voting_session_id where vs.agenda_id = :session1_id "
        sql << ") as s1 on s1.all_delegate_id = ad.id "
      end
      sql << "where ad.parliament_id = :parliament_id "
      sql << "and ad.id in (:all_delegate_ids) "
      if search.present?
        sql << "and ad.first_name like :search "
      end
      if sort_col.present? && sort_dir.present?
        sql << "order by #{sort_col} #{sort_dir} "
      end      
      if limit.present?
        sql << "limit #{limit} "
      end      
      if offset.present?
        sql << "offset #{offset} "
      end      

      x = find_by_sql([sql, :session3_id => a.id, :session2_id => a.session_number2_id, :session1_id => a.session_number1_id, 
                :parliament_id => a.parliament_id, :all_delegate_ids => all_ids,
                :search => "%#{search}%"])

    end
    return x
  end

  def self.update_vote_counts(parliament_id, id=nil)
    # total votes
    x = passed_laws_vote_count(parliament_id, id)
    if x.present?
      update(x.map{|x| x.id}, x.map{|x| {"vote_count" => x.vote_count}}) 
    else
      # no laws are public so make sure vote counts are 0
      z = where(:parliament_id => parliament_id)
      z = z.where(:id => id) if id.present?
      z.update_all(:vote_count => 0)
    end

    # yes votes
    x = passed_laws_yes_count(parliament_id, id)
    if x.present?
      update(x.map{|x| x.id}, x.map{|x| {"yes_count" => x.vote_count}}) 
    else
      # no laws are public so make sure vote counts are 0
      z = where(:parliament_id => parliament_id)
      z = z.where(:id => id) if id.present?
      z.update_all(:yes_count => 0)
    end

    # no votes
    x = passed_laws_no_count(parliament_id, id)
    if x.present?
      update(x.map{|x| x.id}, x.map{|x| {"no_count" => x.vote_count}}) 
    else
      # no laws are public so make sure vote counts are 0
      z = where(:parliament_id => parliament_id)
      z = z.where(:id => id) if id.present?
      z.update_all(:no_count => 0)
    end

    # abstain votes
    x = passed_laws_abstain_count(parliament_id, id)
    if x.present?
      update(x.map{|x| x.id}, x.map{|x| {"abstain_count" => x.vote_count}}) 
    else
      # no laws are public so make sure vote counts are 0
      z = where(:parliament_id => parliament_id)
      z = z.where(:id => id) if id.present?
      z.update_all(:abstain_count => 0)
    end

    # absent votes
    x = passed_laws_absent_count(parliament_id, id)
    if x.present?
      update(x.map{|x| x.id}, x.map{|x| {"absent_count" => x.vote_count}}) 
    else
      # no laws are public so make sure vote counts are 0
      z = where(:parliament_id => parliament_id)
      z = z.where(:id => id) if id.present?
      z.update_all(:absent_count => 0)
    end

    return nil
  end

  # delete all of the delegate records
  # - do this instead of destroy_all for destory all will do hundreds of queries and be slow
  def self.delete_delegate_records(id)
    puts "++++++++++++++++++++++++++++++++++"
    puts "** deleting delegate #{id} **"
    puts "++++++++++++++++++++++++++++++++++"
    if id.present?
      AllDelegate.transaction do
        del = AllDelegate.find_by_id(id)
        if del.present?
          del_ids = Delegate.select('id').where(:all_delegate_id => id)
          VotingResult.where(:delegate_id => del_ids.map{|x| x.id}).delete_all
          Delegate.where(:id => del_ids.map{|x| x.id}).delete_all
          AllDelegate.delete(id)

          # update the vote counts for every law in this parliament
          Agenda.update_law_vote_results(del.parliament_id)
        end
      end
    end
  end

  def self.merge_delegates(id_to_keep, id_to_remove)
    puts "**********************************"
    puts "** to keep = #{id_to_keep}; to remove = #{id_to_remove} **"
    puts "**********************************"
    if id_to_keep.present? && id_to_remove.present?
      AllDelegate.transaction do
        to_keep = AllDelegate.includes(:delegates => :voting_results).where(:id => id_to_keep)
        to_remove = AllDelegate.includes(:delegates => :voting_results).where(:id => id_to_remove)
    
        if to_keep.present? && to_remove.present?
          to_keep_results = to_keep.first.delegates.map{|x| x.voting_results}.flatten

          # merge the impression counts
          to_keep.first.impressions_count += to_remove.first.impressions_count
          to_keep.first.save

          to_remove.first.delegates.each do |del|
            puts "delegate id #{del.id}"          
            update_del_id = false
            del.voting_results.each do |vr|
              puts "- voting record id #{vr.id}"          
              # if to_keep does not have a vote for this session, add it
              # if it does have a vote, assume want to keep the vote for the to_keep record
              if to_keep_results.index{|x| vr.voting_session_id == x.voting_session_id}.nil?
                puts "-- need to copy vote result"          
                # see if delegate record exists for this conference
                to_keep_delegate = to_keep.first.delegates.select{|x| x.conference_id == del.conference_id}
                # if records exists, update vote results record with this id
                # otherwise update to_remove del id to reference id_to_keep
                if to_keep_delegate.present?
                  puts "--- delegate exists for to keep, just updating vote result record"          
                  # record exists, update vote results record to use to_keep del id
                  vr.delegate_id = to_keep_delegate.first.id
                  vr.save
                else
                  puts "--- delegate record not exists"          
                  # update to_remove delegate to reference id_to_keep
                  # - this is actually done after for loop so that
                  #   no errors occur due to changing the id before finished 
                  #   going through all vote records of this delegate
                  update_del_id = true
                end
              end
            end        
            if update_del_id
              puts "---* updating delegate record to be for record to_keep"          
              del.all_delegate_id = to_keep.first.id
              del.first_name = to_keep.first.first_name
              del.xml_id = to_keep.first.xml_id
              del.group_id = to_keep.first.xml_id
              del.title = to_keep.first.title
              del.started_at = to_keep.started_at
              del.ended_at = to_keep.ended_at
              del.save
            end
          end
        end

        # now delete the delegate/voting result records for to_remove
        puts "********** deleting records"          
        delete_delegate_records(id_to_remove)
        
        # now update vote counts of all delegates
        puts "********** updating delegate vote counts"          
        update_vote_counts(to_keep.first.parliament_id)
      end
    end
    puts "**********************************"
    puts "**********************************"
  end
  
  
  
  #######################################
  #######################################
  ### api
  #######################################
  #######################################
  # get all members and their id
  # returns: 
  # [ {id, name, start, end}, {id, name, start, end}, ... ]
  def self.api_v1_members()
    x = []
    members = AllDelegate.select('id, first_name, started_at, ended_at').where(:parliament_id => 1).order("first_name asc")
    if members.present?
      members.each do |member|
        h = Hash.new
        x << h
        h[:id] = member.id
        h[:name] = member.first_name
        h[:start_date] = member.started_at
        h[:end_date] = member.ended_at
      end
    end
    return x
  end

  # get vote history for a member of parliament
  # return: 
=begin
  {
    member:
    {
      internal_id,
      name,
      vote_summary:
      {
        total_votes,
        yes_votes,
        no_votes,
        abstain_votes,
        absent,
      },
      laws: [
        {
          law_id,
          internal_id,
          title,
          released_to_public_at (date law data was made public in our system),
          sessions: 
          {
            session_1: 
            {
              date
              present (yes/no)
              vote (yes/no/abstain)
              summary: 
              {
                total_yes,
                total_no,
                total_abstain,
                total_absent
              }
            },
            session_2: 
            {
              date
              present (yes/no)
              vote (yes/no/abstain)
              summary: 
              {
                total_yes,
                total_no,
                total_abstain,
                total_absent
              }
            },
            session_3: 
            {
              date
              present (yes/no)
              vote (yes/no/abstain)
              vote_summary: 
              {
                total_yes,
                total_no,
                total_abstain,
                total_absent
              }
            }
          }
        },
        { another law },
        { another law } ...
      ]
    }
  }  
=end  
  def self.api_v1_member_votes(member_id, with_laws=false, with_law_vote_summary=false, passed_after=nil, passed_before=nil, made_public_after=nil, made_public_before=nil)
        
    file_path = nil
    
    if member_id.present?
      #create file name
      q = parse_query_params(with_laws, with_law_vote_summary, passed_after, passed_before, made_public_after, made_public_before)
      file_path = "#{JSON_API_MEMBER_VOTES_PATH}/#{member_id}/member_votes_#{member_id}#{q}.json"
      
      # if the path does not exist yet, create it
      FileUtils.mkpath(File.dirname(file_path))
      
      # if the file does not exist yet, create it
      if !File.exists?(file_path)
        h = Hash.new
        member = find_by_id(member_id)
        if member.present?
          # create member hash
          h[:note] = I18n.t('helpers.links.not_present2_footnote')
          h[:member] = Hash.new
          h[:member][:internal_id] = member.id
          h[:member][:name] = member.first_name
          # add vote summary
          vote_summary = Hash.new
          h[:member][:vote_summary] = vote_summary
          vote_summary[:total_votes] = member.vote_count
          vote_summary[:yes_votes] = member.yes_count
          vote_summary[:no_votes] = member.no_count
          vote_summary[:abstain_votes] = member.abstain_count
          vote_summary[:absent] = member.absent_count
          # add laws if desired
          if with_laws
            h[:member][:laws] = []
            
            # get law data
            sql = "select s3.public_url_id, s3.law_id, s3.made_public_at, s3.official_law_title as title, "
            sql << "s1.start_date as s1_date, s1v.present as s1_present, s1v.vote as s1_vote, "
            sql << "s1.result1 as s1_yes_votes, s1.result3 as s1_no_votes, s1.result0 as s1_abstain_votes, s1.not_present as s1_not_present, " if with_law_vote_summary
            sql << "s2.start_date as s2_date, s2v.present as s2_present, s2v.vote as s2_vote, "
            sql << "s2.result1 as s2_yes_votes, s2.result3 as s2_no_votes, s2.result0 as s2_abstain_votes, s2.not_present as s2_not_present, " if with_law_vote_summary
            sql << "s3.start_date as s3_date, s3.present as s3_present, s3.vote as s3_vote "
            sql << ", s3.result1 as s3_yes_votes, s3.result3 as s3_no_votes, s3.result0 as s3_abstain_votes, s3.not_present as s3_not_present " if with_law_vote_summary
            sql << "from (select a.id, a.session_number1_id, a.session_number2_id,  "
            sql << "	a.public_url_id, a.law_id, a.made_public_at, a.official_law_title,  "
            sql << "	c.start_date, vr.present, vr.vote "
            sql << "  , vs.result1, vs.result3, vs.result0, vs.not_present " if with_law_vote_summary
            sql << "	from  "
            sql << "	agendas as a "
            sql << "	inner join conferences as c on c.id = a.conference_id "
            sql << "	inner join voting_sessions as vs on vs.agenda_id = a.id "
            sql << "	inner join voting_results as vr on vr.voting_session_id = vs.id "
            sql << "	inner join delegates as d on vr.delegate_id = d.id "
            sql << "  inner join all_delegates as ad on d.all_delegate_id = ad.id "
            sql << "	where d.all_delegate_id = :all_delegate_id "
            sql << "  and (ad.started_at is null or ad.started_at <= c.start_date) and (ad.ended_at is null or ad.ended_at >= c.start_date) "
            sql << "	and a.is_public = 1 and a.public_url_id is not null "
            if passed_after.present?
              sql << "and c.start_date >= :passed_after "
            end
            if passed_before.present?
              sql << "and c.start_date <= :passed_before "
            end
            if made_public_after.present?
              sql << "and a.made_public_at >= :made_public_after "
            end
            if made_public_before.present?
              sql << "and a.made_public_at <= :made_public_before "
            end
            sql << ") as s3 "
            sql << "left join ( "
            sql << "	select a.id, c.start_date, vs.id as voting_session_id "
            sql << "  , vs.result1, vs.result3, vs.result0, vs.not_present " if with_law_vote_summary
            sql << "	from  "
            sql << "	agendas as a "
            sql << "	inner join conferences as c on c.id = a.conference_id "
            sql << "	inner join voting_sessions as vs on vs.agenda_id = a.id "
            sql << ") as s2 on s2.id = s3.session_number2_id "
            sql << "left join ( "
            sql << "	select a.id, c.start_date, vs.id as voting_session_id "
            sql << "  , vs.result1, vs.result3, vs.result0, vs.not_present " if with_law_vote_summary
            sql << "	from  "
            sql << "	agendas as a "
            sql << "	inner join conferences as c on c.id = a.conference_id "
            sql << "	inner join voting_sessions as vs on vs.agenda_id = a.id "
            sql << ") as s1 on s1.id = s3.session_number1_id "
            sql << "left join ( "
            sql << "	select vr.present, vr.vote, vr.voting_session_id "
            sql << "	from  "
            sql << "	voting_results as vr "
            sql << "	inner join delegates as d on vr.delegate_id = d.id "
            sql << "	where d.all_delegate_id = :all_delegate_id "
            sql << ") as s2v on s2v.voting_session_id = s2.voting_session_id "
            sql << "left join ( "
            sql << "	select vr.present, vr.vote, vr.voting_session_id "
            sql << "	from  "
            sql << "	voting_results as vr "
            sql << "	inner join delegates as d on vr.delegate_id = d.id "
            sql << "	where d.all_delegate_id = :all_delegate_id "
            sql << ") as s1v on s1v.voting_session_id = s1.voting_session_id "
            sql << "order by s3.start_date desc "
            
            member_laws = find_by_sql([sql, :all_delegate_id => member_id, 
                :passed_after => passed_after, :passed_before => passed_before, 
                :made_public_before => made_public_before, :made_public_after => made_public_after])
                
            if member_laws.present?
              # populate the law array            
              member_laws.each do |member_law|
                law = Hash.new
                h[:member][:laws] << law
                
                law[:internal_id] = member_law[:public_url_id]
                law[:law_id] = member_law[:law_id]
                law[:title] = member_law[:title]
                law[:released_to_public_at] = member_law[:made_public_at]
                sessions = Hash.new
                law[:sessions] = sessions
                # if the law does not have a first or second session, 
                # then law is 1 hearing only
                if member_law[:s1_date].present? && member_law[:s2_date].present?
                  s1 = Hash.new
                  sessions[:session_1] = s1
                  s1[:date] = member_law[:s1_date]
                  s1[:present] = format_present(member_law[:s1_present])
                  s1[:vote] = format_vote(member_law[:s1_vote])
                  if with_law_vote_summary
                    session1_vote_summary = Hash.new
                    s1[:vote_summary] = session1_vote_summary
                    session1_vote_summary[:yes_votes] = member_law[:s1_yes_votes]
                    session1_vote_summary[:no_votes] = member_law[:s1_no_votes]
                    session1_vote_summary[:abstain_votes] = member_law[:s1_abstain_votes]
                    session1_vote_summary[:absent] = member_law[:s1_not_present]
                  end
                  
                  s2 = Hash.new
                  sessions[:session_2] = s2
                  s2[:date] = member_law[:s2_date]
                  s2[:present] = format_present(member_law[:s2_present])
                  s2[:vote] = format_vote(member_law[:s2_vote])
                  if with_law_vote_summary
                    session2_vote_summary = Hash.new
                    s2[:vote_summary] = session2_vote_summary
                    session2_vote_summary[:yes_votes] = member_law[:s2_yes_votes]
                    session2_vote_summary[:no_votes] = member_law[:s2_no_votes]
                    session2_vote_summary[:abstain_votes] = member_law[:s2_abstain_votes]
                    session2_vote_summary[:absent] = member_law[:s2_not_present]
                  end
                  
                  s3 = Hash.new
                  sessions[:session_3] = s3
                  s3[:date] = member_law[:s3_date]
                  s3[:present] = format_present(member_law[:s3_present])
                  s3[:vote] = format_vote(member_law[:s3_vote])
                  if with_law_vote_summary
                    session3_vote_summary = Hash.new
                    s3[:vote_summary] = session3_vote_summary
                    session3_vote_summary[:yes_votes] = member_law[:s3_yes_votes]
                    session3_vote_summary[:no_votes] = member_law[:s3_no_votes]
                    session3_vote_summary[:abstain_votes] = member_law[:s3_abstain_votes]
                    session3_vote_summary[:absent] = member_law[:s3_not_present]
                  end
                else 
                  s1 = Hash.new
                  sessions[:session_1] = s1
                  s1[:date] = member_law[:s3_date]
                  s1[:present] = format_present(member_law[:s3_present])
                  s1[:vote] = format_vote(member_law[:s3_vote])
                  if with_law_vote_summary
                    session1_vote_summary = Hash.new
                    s1[:vote_summary] = session1_vote_summary
                    session1_vote_summary[:yes_votes] = member_law[:s3_yes_votes]
                    session1_vote_summary[:no_votes] = member_law[:s3_no_votes]
                    session1_vote_summary[:abstain_votes] = member_law[:s3_abstain_votes]
                    session1_vote_summary[:absent] = member_law[:s3_not_present]
                  end
                end
                
              end
            end
          end
        end
        File.open(file_path, 'a') {|f| f << h.to_json }
      end
    end
    return file_path
  end

  # returns: array of member_votes
  def self.api_v1_all_member_votes(with_laws=false, with_law_vote_summary=false, passed_after=nil, passed_before=nil, made_public_after=nil, made_public_before=nil)
    #create file name
    q = parse_query_params(with_laws, with_law_vote_summary, passed_after, passed_before, made_public_after, made_public_before)
    file_path = "#{JSON_API_ALL_MEMBER_VOTES_PATH}/all_member_votes#{q}.json"
    
    # if the path does not exist yet, create it
    FileUtils.mkpath(File.dirname(file_path))
    
    # if the file does not exist yet, create it
    if !File.exists?(file_path)
      members = api_v1_members
      if members.present?
        File.open(file_path, 'a') {|f| f << '[' }
        members.each_with_index do |member, i|
          # create the member vote data
          member_file = api_v1_member_votes(member[:id], with_laws, with_law_vote_summary, passed_after, passed_before, made_public_after, made_public_before)
          # read in the data
          member_data = File.open(member_file, "r") {|f| f.read()} 
          add_comma = i == members.length-1 ? '' : ','
          # add the member data
          File.open(file_path, 'a') {|f| f << member_data + add_comma } if member_data.present?
        end
        File.open(file_path, 'a') {|f| f << ']' }
      end
    end
    
    return file_path
  end
  
protected

  def self.passed_laws_vote_count_query
    sql = "select ad.id, ad.first_name, if(isnull(x.vote_count), 0, x.vote_count) as vote_count "
    sql << "from all_delegates as ad "
    sql << "left join ("
    sql << "select ad.id, ad.first_name, count(*) as vote_count "
    sql << "from all_delegates as ad "
    sql << "inner join delegates as d on d.all_delegate_id = ad.id "
    sql << "inner join conferences as c on c.id = d.conference_id "
    sql << "inner join agendas as a on a.conference_id = c.id "
    sql << "inner join voting_sessions as vs on vs.agenda_id = a.id "
    sql << "inner join voting_results as vr on vr.voting_session_id = vs.id and vr.delegate_id = d.id "
    sql << "inner join upload_files as uf on uf.id = c.upload_file_id "
    sql << "where a.is_law = 1 and a.is_public = 1 and vs.passed = 1 and uf.is_deleted = 0 and a.public_url_id is not null and a.public_url_id != '' "
    sql << "and ad.parliament_id = :parl_id "
    sql << "and (ad.started_at is null or ad.started_at <= c.start_date) and (ad.ended_at is null or ad.ended_at >= c.start_date) "
    sql << "[placeholder] "    
    sql << "[id_placeholder] "    
    sql << "group by ad.id, ad.first_name "
    sql << ") as x on x.id = ad.id "
    sql << "where ad.parliament_id = :parl_id "
    sql << "[id_placeholder] "    
  end

  def self.passed_laws_vote_count(parliament_id,id=nil)
    sql = passed_laws_vote_count_query.gsub('[placeholder]', 'and vr.present = 1')
    if id.present?
      sql = sql.gsub('[id_placeholder]', "and ad.id = :id ")
    else
      sql = sql.gsub('[id_placeholder]', "")
    end
    find_by_sql([sql, :parl_id => parliament_id, :id => id])
  end

  def self.passed_laws_yes_count(parliament_id,id=nil)
    sql = passed_laws_vote_count_query.gsub('[placeholder]', 'and vr.vote = 1 and vr.present = 1')
    if id.present?
      sql = sql.gsub('[id_placeholder]', "and ad.id = :id ")
    else
      sql = sql.gsub('[id_placeholder]', "")
    end
    find_by_sql([sql, :parl_id => parliament_id, :id => id])
  end

  def self.passed_laws_no_count(parliament_id,id=nil)
    sql = passed_laws_vote_count_query.gsub('[placeholder]', 'and vr.vote = 3 and vr.present = 1')
    if id.present?
      sql = sql.gsub('[id_placeholder]', "and ad.id = :id ")
    else
      sql = sql.gsub('[id_placeholder]', "")
    end
    find_by_sql([sql, :parl_id => parliament_id, :id => id])
  end

  def self.passed_laws_abstain_count(parliament_id,id=nil)
    sql = passed_laws_vote_count_query.gsub('[placeholder]', 'and vr.vote = 0 and vr.present = 1')
    if id.present?
      sql = sql.gsub('[id_placeholder]', "and ad.id = :id ")
    else
      sql = sql.gsub('[id_placeholder]', "")
    end
    find_by_sql([sql, :parl_id => parliament_id, :id => id])
  end

  def self.passed_laws_absent_count(parliament_id,id=nil)
    sql = passed_laws_vote_count_query.gsub('[placeholder]', 'and vr.present = 0')
    if id.present?
      sql = sql.gsub('[id_placeholder]', "and ad.id = :id ")
    else
      sql = sql.gsub('[id_placeholder]', "")
    end
    find_by_sql([sql, :parl_id => parliament_id, :id => id])
  end


  def self.format_present(present)
    present == 1 ? I18n.t('helpers.boolean.y') : I18n.t('helpers.boolean.n')
  end

  def self.format_vote(vote)
    case vote
      when 0
        I18n.t('helpers.boolean.abstain')
      when 1
        I18n.t('helpers.boolean.y')
      when 3
        I18n.t('helpers.boolean.n')
      else
        I18n.t('helpers.links.not_present')
    end
  end

  def self.parse_query_params(with_laws=false, with_law_vote_summary=false, passed_after=nil, passed_before=nil, made_public_after=nil, made_public_before=nil)
    # parse params for file name
    q = ""
    q << "_wl" if with_laws
    q << "_wlvs" if with_law_vote_summary
    q << "_pa_#{passed_after}" if passed_after.present?
    q << "_pb_#{passed_before}" if passed_before.present?
    q << "_mpa_#{made_public_after}" if made_public_after.present?
    q << "_mpb_#{made_public_before}" if made_public_before.present?
    return q
  end
end
