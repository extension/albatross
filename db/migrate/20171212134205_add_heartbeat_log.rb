class AddHeartbeatLog < ActiveRecord::Migration
  def change
    create_table :monitored_server_heartbeats do |t|
      t.integer     "monitored_server_id", null: false
      t.datetime    "created_at"
    end
  end

end
