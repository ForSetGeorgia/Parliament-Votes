class AddMissingAllDelId < ActiveRecord::Migration
  def up
    Delegate.transaction do
      update_count = 0
      Delegate.select("distinct first_name, xml_id").where("all_delegate_id is null").each do |member|
        # look for all delegate record
        ad = AllDelegate.where(:first_name => member.first_name, :xml_id => member.xml_id)
        if ad.present?
          puts "updating #{ad.first.first_name}"
          update_count += 1
          # found a match, add id to delegate records
          Delegate.where(["first_name = ? and xml_id = ? and all_delegate_id is null", member.first_name, member.xml_id]).update_all(:all_delegate_id => ad.first.id)
        end
      end
      puts "updated #{update_count} delegates"
    end
  end

  def down
    # do nothing
  end
end
