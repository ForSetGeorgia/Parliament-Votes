class CreateNicknames < ActiveRecord::Migration
  def up
    User.all.each do |u|
      u.nickname = u.email.split('@')[0]
      u.save
    end
  end

  def down
    User.update_all(:nickname => nil)
  end
end
