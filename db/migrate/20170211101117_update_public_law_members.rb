class UpdatePublicLawMembers < ActiveRecord::Migration
  def up
    start = Time.now
    # update the agenda stats since 13 people were missing
    Agenda.with_parliament([3]).public_laws.each do |agenda|
      agenda.update_records_for_public_law(true)
    end

    puts "this took #{Time.now-start} seconds"
  end

  def down
    puts "do nothing"
  end
end
