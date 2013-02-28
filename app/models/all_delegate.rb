class AllDelegate < ActiveRecord::Base
  has_paper_trail

  attr_accessible :xml_id, :group_id, :first_name, :title


  # get the delegates that were not present
  def self.available_delegates(agenda_id)
    # get all delegates in the conference
    used_delegates = Delegate.joins(:voting_results => :voting_session).select("distinct delegates.xml_id").where("voting_sessions.agenda_id = ?", agenda_id)
    if used_delegates.present?
      AllDelegate.where("xml_id not in (?)", used_delegates.map{|x| x.xml_id}).order("first_name")
    else
      AllDelegate.order("first_name")
    end
  end

  def self.add_if_new(delegates)
    if delegates.present?
      delegates.each do |delegate|
        exists = AllDelegate.where(:xml_id => delegate.xml_id, :first_name => delegate.first_name)

        if !exists.present?
          AllDelegate.create(:xml_id => delegate.xml_id, :first_name => delegate.first_name)
        end
      end
    end
  end

end
