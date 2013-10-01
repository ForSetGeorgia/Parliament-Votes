class FixMoreDuplicates < ActiveRecord::Migration
  def up
    AllDelegate.transaction do
      AllDelegate.merge_delegates(325, 328)
      AllDelegate.merge_delegates(326, 329)
      AllDelegate.merge_delegates(327, 330)

      # clear out json api files
      FileUtils.rm_rf(AllDelegate::JSON_API_PATH)
    end
  end

  def down
    # do nothing
  end
end
