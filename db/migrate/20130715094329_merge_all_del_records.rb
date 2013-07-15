class MergeAllDelRecords < ActiveRecord::Migration
  def up
    AllDelegate.transaction do
      AllDelegate.merge_delegates(325, 160)
      AllDelegate.merge_delegates(326, 161)
      AllDelegate.merge_delegates(327, 162)
      AllDelegate.merge_delegates(144, 78)
    end
  end

  def down
    # do nothing
  end
end
