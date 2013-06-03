class UpdateVoteCounts < ActiveRecord::Migration
  def up
    Parliament.all.each do |p|
      AllDelegate.update_vote_counts(p.id)
    end
  end

  def down
    # do nothing
  end
end
