class AddDelegateNotificationFlag < ActiveRecord::Migration
  def up
    Notification.transaction do
      User.where('role >= 25 && wants_notifications = 1').each do |user|
        Notification.create(:user_id => user.id, :notification_type => Notification::TYPES[:new_delegate])
      end
    end
  end

  def down
    Notification.where(:notification_type => Notification::TYPES[:new_delegate]).delete_all
  end
end
