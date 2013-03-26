class UserNotification < ActiveRecord::Migration
  def change
    add_column :users, :wants_notifications, :boolean, :default => true
    add_column :users, :notification_language, :string
    add_index "users", "notification_language"
    add_index "users", "wants_notifications"

    create_table "notifications", :force => true do |t|
      t.integer  "user_id"
      t.integer  "notification_type"
      t.integer  "identifier"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "notifications", ["notification_type", "identifier"], :name => "idx_notif_type"
    add_index "notifications", "user_id"

  end
end
