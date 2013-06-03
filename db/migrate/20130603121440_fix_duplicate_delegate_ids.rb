class FixDuplicateDelegateIds < ActiveRecord::Migration
  def up
    Delegate.transaction do
      ids_to_delete = []

      # get duplicate delegate records
      puts 'getting duplicate delegate records'
      sql = "select conference_id, all_delegate_id from (select conference_id, all_delegate_id, count(*) as c "
      sql << "from delegates "
      sql << "group by conference_id, all_delegate_id "
      sql << "order by conference_id, all_delegate_id) as x "
      sql << "where x.c > 1 and x.all_delegate_id is not null"
      dups = Delegate.find_by_sql(sql)

      puts "there are #{dups.length} duplicate delegate records to fix"

      # for each duplicate, update voting record to use older id and then delete the newer delegate record
      dups.each do |dup|
        d = Delegate.where(:conference_id => dup.conference_id, :all_delegate_id => dup.all_delegate_id).order("created_at asc")
        # first record is the one to keep, the second is the one to delete
        VotingResult.where(:delegate_id => d[1].id).update_all(:delegate_id => d[0].id)
        
        ids_to_delete << d[1].id
      end

      # delete the dup records
      puts 'deleting duplicate records'
      Delegate.where(:id => ids_to_delete).delete_all
    end
  end

  def down
    # do nothing
  end
end
