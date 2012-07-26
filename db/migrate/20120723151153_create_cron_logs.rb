class CreateCronLogs < ActiveRecord::Migration
  def change
    create_table :cron_logs do |t|
      t.references :cron
      t.text        "stdout", :limit => 16777215
      t.text        "stderr", :limit => 16777215
      t.string      "command"
      t.string      "server"
      t.datetime    "started_at"
      t.datetime    "finished_at"
      t.float       "runtime"      
      t.timestamps
    end
  end
end
