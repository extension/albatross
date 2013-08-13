class DropNotifyPrefs < ActiveRecord::Migration
  def up
    drop_table('notification_prefs')
  end

  def down
  end
end
