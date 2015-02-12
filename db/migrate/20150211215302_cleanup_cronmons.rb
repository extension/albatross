class CleanupCronmons < ActiveRecord::Migration
  def up
    # null left joins are  way, way, way, way faster than the dependent delete
    # - mainly because there's 159,000+ cronmon_logs for the old servers
    execute "DELETE from cronmon_servers where last_heartbeat_at is NULL or YEAR(last_heartbeat_at) != 2015"
    execute "DELETE cronmons.* from cronmons left join cronmon_servers on cronmon_servers.id = cronmons.cronmon_server_id where cronmon_servers.id is NULL"
    execute "DELETE cronmon_logs.* from cronmon_logs left join cronmons on cronmons.id = cronmon_logs.cronmon_id where cronmons.id  is NULL"
    execute "DELETE cronmon_log_outputs.* from cronmon_log_outputs left join cronmon_logs on cronmon_logs.id = cronmon_log_outputs.cronmon_log_id where cronmon_logs.id is NULL"
  end

end
