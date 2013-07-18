class CronmonTables < ActiveRecord::Migration
  def change

    # create a Doorkeeper Application for cronmon
    cronmon = Doorkeeper::Application.new(name: 'cronmon')
    cronmon.secret = SecureRandom.urlsafe_base64(20)
    cronmon.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    cronmon.owner = Coder.coderbot
    cronmon.save
    cronmon.update_column(:uid,'cronmon-registration')
    

    create_table :cronmon_servers do |t|
      t.string   :name,         :null => false
      t.text     :sysinfo
      t.datetime :last_cron_at      
      t.timestamps
    end

    add_index('cronmon_servers',['name'], name: 'server_name_ndx', unique: true)

    create_table :cronmons do |t|
      t.integer     'cron_server_id', :null => false  
      t.string      "label", :null => false
      t.boolean     "error_notification", :null => false, :default => true
      t.timestamps
    end

    add_index('cronmons',['cron_server_id','label'], name: 'cronmon_ndx', unique: true)

    create_table :cronmon_logs do |t|
      t.integer     "cronmon_id"
      t.text        "command"
      t.datetime    "start"
      t.datetime    "finish"
      t.boolean     "success"
      t.float       "runtime"      
      t.timestamps
    end

    add_index('cronmon_logs',['cronmon_id'], name: 'cronmon_ndx')

    create_table :cronmon_log_outputs do |t|
      t.integer     "cronmon_log_id"
      t.text        "stdout", :limit => 16777215
      t.text        "stderr", :limit => 16777215
      t.datetime    "created_at"
    end      

    add_index('cronmon_log_outputs',['cronmon_log_id'], name: 'cronmon_log_ndx')


  end
end
