class FixExtraSpaceAgain < ActiveRecord::Migration
  def up
    AllDelegate.transaction do
      # update all names and strip space at end
      AllDelegate.where("right(first_name, 1) = ' '").each do |ad|
        ad.first_name.strip!
        # rails does not see the stripping of a space as a change, so force it to see the change
        ad.first_name_will_change!
        ad.save
      end
      Delegate.where("right(first_name, 1) = ' '").each do |d|
        d.first_name.strip!
        # rails does not see the stripping of a space as a change, so force it to see the change
        d.first_name_will_change!
        d.save
      end

      # now assign all delegate id for xml id 8891
      Delegate.where('xml_id = 8891 and all_delegate_id is null').update_all(:all_delegate_id => 76)
      
      # now update vote count
      AllDelegate.update_vote_counts(1, 76)
    end
  end

  def down
    # do nothing
  end
end
