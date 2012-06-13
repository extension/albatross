class NotificationPrefs < ActiveRecord::Migration
    def change
      create_table :notification_prefs do |t|
        t.references :coder
        t.references :application
        t.boolean    "notify"
        t.timestamps
      end
    end
end
