class CreateNumMembersData < ActiveRecord::Migration
  def up
=begin
    files = UploadFile.select('distinct upload_files.id, upload_files.xml_file_name, agendas.number_possible_members as number_members').joins(:conference => :agendas)
    files.each do |file|
      file.number_possible_members = file.attributes["number_members"]
      file.save
    end
=end
  end

  def down
    UploadFile.update_all(:number_possible_members => 150)
  end
end
