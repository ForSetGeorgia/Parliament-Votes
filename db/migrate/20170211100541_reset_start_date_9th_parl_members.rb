class ResetStartDate9thParlMembers < ActiveRecord::Migration
  def up
    AllDelegate.where(parliament_id: 3).update_all(started_at: nil)
  end

  def down
    puts "do nothing"
  end
end
