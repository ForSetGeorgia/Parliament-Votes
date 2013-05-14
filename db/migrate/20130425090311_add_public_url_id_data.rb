class AddPublicUrlIdData < ActiveRecord::Migration
  def up
    Agenda.not_deleted.final_laws.public.joins(:conference).order('conferences.start_date asc, agendas.official_law_title asc').readonly(false).each_with_index do |law, index|
      law.public_url_id = index+1
      law.save
    end

    # update vote counts
    AllDelegate.update_vote_counts(1)
  end

  def down
    Agenda.update_all(:public_url_id => nil)
  end
end
