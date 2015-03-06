class ChangeUpServers < ActiveRecord::Migration
  def up
    rename_table(:cronmon_servers, :monitored_servers)
    rename_column(:cronmons, "cronmon_server_id", "monitored_server_id")
    add_column(:monitored_servers, :purpose, :string)
    add_column(:applications, :description, :text)
    # 1 to 1 for now
    add_column(:applications, :monitored_server_id, :integer)
    execute "UPDATE oauth_applications SET owner_type = 'MonitoredServer' where owner_type = 'CronmonServer'"
  end

  def down
  end
end
