class AddAllDelIdData < ActiveRecord::Migration
  def up
    connection = ActiveRecord::Base.connection()
    sql = "update delegates as d, all_delegates as ad set d.all_delegate_id = ad.id where d.xml_id = ad.xml_id and d.first_name = ad.first_name"
    connection.execute(sql)
    
  end

  def down
    Delegate.update_all(:all_delegate_id => nil)
  end
end
