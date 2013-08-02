class LegacyCronIndexes < ActiveRecord::Migration
  def change
    add_index('cron_logs',['cron_id'], name: 'cron_ndx')
  end

end
