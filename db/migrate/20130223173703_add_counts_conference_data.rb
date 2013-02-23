class AddCountsConferenceData < ActiveRecord::Migration
  def up
    Conference.all.each do |conf|
      conf.number_laws = conf.agendas.select{|x| x.is_law == true}.count
      conf.number_sessions = conf.agendas.count
      conf.save
    end
  end

  def down
    Conference.update_all(:number_laws => 0, :number_sessions => 0)
  end
end
