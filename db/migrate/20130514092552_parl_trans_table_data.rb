# encoding: UTF-8
class ParlTransTableData < ActiveRecord::Migration
  def up
    ParliamentTranslation.create(:parliament_id => 2, :locale => 'ka', :name => 'მე-7 მოწვევის პარლამენტი')
    ParliamentTranslation.create(:parliament_id => 2, :locale => 'en', :name => 'The 7th Parliament')

    ParliamentTranslation.create(:parliament_id => 1, :locale => 'ka', :name => 'მე-8 მოწვევის პარლამენტი')
    ParliamentTranslation.create(:parliament_id => 1, :locale => 'en', :name => 'The 8th Parliament')
  end

  def down
    ParliamentTranslation.delete_all
  end
end
