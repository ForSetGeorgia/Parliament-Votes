class FixSpeextraSpace < ActiveRecord::Migration
  def up
    AllDelegate.transaction do
      # update all names and strip space at end
      AllDelegate.where("right(first_name, 1) = ' '").each do |ad|
        ad.first_name.strip!
        ad.save
      end
      Delegate.where("right(first_name, 1) = ' '").each do |d|
        d.first_name.strip!
        d.save
      end

      # now fix the duplicate name with an extra space
      AllDelegate.merge_delegates(325,332)
    end
  end

  def down
    # do nothing
  end
end
