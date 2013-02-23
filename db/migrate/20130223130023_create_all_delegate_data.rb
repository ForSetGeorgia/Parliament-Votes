class CreateAllDelegateData < ActiveRecord::Migration
  def up
    delegates = Delegate.select("distinct xml_id, first_name")

    delegates.each do |delegate|
      AllDelegate.create(:xml_id => delegate.xml_id, :first_name => delegate.first_name)
    end

  end

  def down
    AllDelegate.delete_all
  end
end
