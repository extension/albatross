class AddBackupLogs < ActiveRecord::Migration
  def change
    create_table :backups do |t|
      t.integer     "monitored_server_id"
      t.text        "backupcommand"
      t.string      "server_name"
      t.string      "server_fqdn"
      t.datetime    "start"
      t.datetime    "finish"
      t.float       "runtime"
      t.boolean     "success"
      t.text        "stdout"
      t.text        "stderr"
      t.datetime    "created_at"
    end

    add_column(:monitored_servers, :last_backup_at, :datetime, :null => true)

  end
end
