class AddMemberStartDates < ActiveRecord::Migration
  def up
    AllDelegate.transaction do
      # new members
      ad = AllDelegate.find_by_id(325)
      ad.started_at = '2013-05-17'
      ad.save
      ad.check_for_date_changes

      ad = AllDelegate.find_by_id(326)
      ad.started_at = '2013-05-17'
      ad.save
      ad.check_for_date_changes

      ad = AllDelegate.find_by_id(327)
      ad.started_at = '2013-05-17'
      ad.save
      ad.check_for_date_changes

      ad = AllDelegate.find_by_id(331)
      ad.started_at = '2013-12-11'
      ad.save
      ad.check_for_date_changes



      # members leaving
      ad = AllDelegate.find_by_id(21)
      ad.ended_at = '2013-11-27'
      ad.save
      ad.check_for_date_changes

    end      
  end

  def down
    ads = AllDelegate.where('started_at is not null or ended_at is not null')
    if ads.present?
      AllDelegate.transaction do
        ads.each do |ad|
          ad.started_at = nil
          ad.ended_at = nil
          ad.save
          ad.check_for_date_changes
        end
      end
    end
  end
end
