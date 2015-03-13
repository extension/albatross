class CleanupEngbotLogs < ActiveRecord::Migration
  def change
    remove_column(:engbot_logs, :monitored_server_id)
    remove_column(:engbot_logs, :application_id)
  end

end
