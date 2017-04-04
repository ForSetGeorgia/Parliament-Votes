class AddMissingAdId < ActiveRecord::Migration
  def up
    # for some reason some delegate records do not have all_delegate_id while others do
    # for each all_delegate, update delegate records with the all_delegate_id for the matching xml_id
    parliament_id = 3 
    AllDelegate.transaction do
      AllDelegate.where(parliament_id: parliament_id).each do |all_delegate|
        Delegate.where('xml_id = ? and all_delegate_id is null', all_delegate.xml_id).update_all(all_delegate_id: all_delegate.id)
      end
    end

    AllDelegate.update_vote_counts(parliament_id)
    FileUtils.rm_rf(AllDelegate::JSON_API_PATH)
  end

  def down
    puts "do nothing"
  end
end
