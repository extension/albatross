class CreateCronLogs < ActiveRecord::Migration
  def change
    create_table :cron_logs do |t|
      t.references :cron
      t.string      "stdout"
      t.string      "stderr"
      t.string      "command"
      t.string      "server"
      t.datetime    "started_at"
      t.datetime    "finished_at"
      t.float       "runtime"      
      t.timestamps
    end
  end
end
