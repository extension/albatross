class AddRebootChecks < ActiveRecord::Migration
  def change
    add_column(:monitored_servers, :needs_reboot, :boolean, null: false, default: false)
    add_column(:monitored_servers, :last_rebootcheck_at, :datetime, null: true)

    create_table :monitored_server_reboot_checks do |t|
      t.integer     "monitored_server_id", null: false
      t.text        "rebootinfo"
      t.boolean     "needs_reboot", null: false, default: false
      t.datetime    "created_at"
    end
  end
end
