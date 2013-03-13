# encoding: UTF-8

=begin
User.create(:email => 'jason.addie@jumpstart.ge', :password => 'password', :role => 99)
User.create(:email => 'eric@jumpstart.ge', :password => 'password', :role => 99)
User.create(:email => 'tsartania@ndi.ge', :password => 'password', :role => 50)
User.create(:email => 'tamaz@parliament.ge', :password => 'password', :role => 25)
=end

Parliament.delete_all
Parliament.create(:id => 1, :name => 'მე-8 მოწვევის პარლამენტი', :start_date => '21-10-2012')
Parliament.create(:id => 2, :name => 'მე-7 მოწვევის პარლამენტი')
