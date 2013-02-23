class CreateAllDelegateData < ActiveRecord::Migration
  def up
    # get unique delegates from laws
    delegates = Delegate.joins(:voting_results => {:voting_session => :agenda}).select("distinct delegates.xml_id, delegates.first_name").where("agendas.is_law = 1")
                

    delegates.each do |delegate|
      AllDelegate.create(:xml_id => delegate.xml_id, :first_name => delegate.first_name)
    end

  end

  def down
    AllDelegate.delete_all
  end
end
