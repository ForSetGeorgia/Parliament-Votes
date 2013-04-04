class AddParlIdDelegatesData < ActiveRecord::Migration
  def up
    AllDelegate.update_all(:parliament_id => 1)
  end

  def down
    AllDelegate.update_all(:parliament_id => nil)
  end
end
