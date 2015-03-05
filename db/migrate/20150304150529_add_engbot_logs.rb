class AddEngbotLogs < ActiveRecord::Migration
  def change

    create_table :engbot_logs do |t|
      t.integer    "coder_id", :default => 1
      t.integer    "monitored_server_id"
      t.integer    "application_id"
      t.string     "slack_channel_id"
      t.string     "slack_channel_name"
      t.string     "slack_user_id"
      t.string     "slack_user_name"
      t.string     "command"
      t.text       "commandtext"
      t.datetime   "created_at"
    end

  end
end
