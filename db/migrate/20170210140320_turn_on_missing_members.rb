class TurnOnMissingMembers < ActiveRecord::Migration
  def up
    members = [61318, 61289, 61341, 61349, 61288, 61259, 61250, 61328, 61333, 61248, 61284, 61344, 62454]
    parl_id = 3
    total_count = 0

    # create all delegate records
    # and assign the ids to the delegate records
    members.each do |member_id|
      puts '-----------'
      puts member_id

      delegates = Delegate.where(xml_id: member_id)
      if delegates.present?
        # create all delegate record
        delegate = delegates.first
        all_delegate = AllDelegate.create(
          :xml_id => delegate.xml_id, 
          :first_name => delegate.first_name_ka.strip, 
          :parliament_id => parl_id, 
          :started_at => '2016-11-26'
        )

        # now assign the id to all delegate records
        count = delegates.update_all(all_delegate_id: all_delegate.id)
        total_count += count
        puts "- added id to #{count} records"

      end
    end

    puts "----------------------------"
    puts "added ids to #{total_count} delegate records"

  end

  def down

  end
end
