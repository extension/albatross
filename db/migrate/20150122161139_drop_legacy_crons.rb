class DropLegacyCrons < ActiveRecord::Migration
  def up
    drop_table("crons")
    drop_table("cron_logs")
  end

end
