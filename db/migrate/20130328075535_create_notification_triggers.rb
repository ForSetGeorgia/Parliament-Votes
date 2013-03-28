class CreateNotificationTriggers < ActiveRecord::Migration
  def change
    create_table :notification_triggers do |t|
      t.integer :notification_type
      t.integer :identifier
      t.boolean :processed, :default => false

      t.timestamps
    end

    add_index :notification_triggers, :notification_type

  end
end
