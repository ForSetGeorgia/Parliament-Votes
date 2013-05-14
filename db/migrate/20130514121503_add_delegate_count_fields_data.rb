class AddDelegateCountFieldsData < ActiveRecord::Migration
  def up
    Parliament.all.each do |p|
      AllDelegate.update_vote_counts(p.id)
    end
  end

  def down
    AllDelegate.update_all(:yes_count => 0, :no_count => 0, :abstain_count => 0, :absent_count => 0)
  end
end
