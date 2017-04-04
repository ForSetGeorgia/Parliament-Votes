class MergeDuplicateMembers < ActiveRecord::Migration
  def up
    AllDelegate.transaction do
      AllDelegate.merge_delegates(579, 416)

      # clear out json api files
      FileUtils.rm_rf(AllDelegate::JSON_API_PATH)
    end
  end

  def down
    puts "do nothing"
  end
end
