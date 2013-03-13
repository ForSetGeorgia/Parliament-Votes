class AddParliamentIdFilesData < ActiveRecord::Migration
  def up
    UploadFile.update_all(:parliament_id => 1)
  end

  def down
    UploadFile.update_all(:parliament_id => nil)
  end
end
