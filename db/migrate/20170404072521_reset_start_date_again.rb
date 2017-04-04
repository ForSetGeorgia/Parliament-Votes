class ResetStartDateAgain < ActiveRecord::Migration
  def up
    parliament_id = 3
    AllDelegate.where(parliament_id: parliament_id).update_all(started_at: nil)
    AllDelegate.update_vote_counts(parliament_id)
    FileUtils.rm_rf(AllDelegate::JSON_API_PATH)
  end

  def down
    puts "do nothing"
  end
end
