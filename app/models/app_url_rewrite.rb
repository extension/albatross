# === COPYRIGHT:
# Copyright (c) North Carolina State University
# === LICENSE:
# see LICENSE file
class AppUrlRewrite < ActiveRecord::Base
  extend IoUtils
  belongs_to :application
  has_many :app_url_rewrite_logs


  PRODUCTION = 'production'
  STAGING = 'staging'
  LOCALDEV = 'localdev'

  def rewrite_wordpress_urls(debug_srdb = false)
    if(self.location == STAGING)
      if(dbname = self.application.get_staging_dbname)
        host = Settings.data_dump_mysql_host_aws_dev
        port = Settings.data_dump_mysql_host_aws_dev_port
      else
        raise "Application: #{self.application.name} has no staging database"
      end
    elsif(self.location == LOCALDEV)
      if(dbname = self.application.get_scrubhost_dbname)
        host = Settings.data_dump_mysql_host_scrubbed
        port = Settings.data_dump_mysql_host_scrubbed_port
      else
        raise "Application: #{self.application.name} has no scrubbing database"
      end
    else
      raise "Unknown rewrite location: #{self.location}"
    end

    base_srdb_options = {}
    base_srdb_options[:dbname] = dbname
    base_srdb_options[:host] = host
    base_srdb_options[:port] = port
    base_srdb_options[:user] = Settings.data_mysql_albatross_user
    base_srdb_options[:pass] = Settings.data_mysql_albatross_pass
    base_srdb_options[:debug] = debug_srdb

    started = Time.now

    # first pass: http(s)://search_host with http(s)://replace_host
    search_regex = "'~(https?:\\/\\/)#{Regexp.escape(self.search_host)}~'"
    replace_regex = "'$1#{self.replace_host}'"
    pass_one = self.class._wp_srdb_database(base_srdb_options.merge(search_url: search_regex, replace_url: replace_regex, is_regex: true))

    # second pass: search_host with replace_host
    search_regex = "'~^#{Regexp.escape(self.search_host)}~'"
    replace_regex = "'#{self.replace_host}'"
    pass_two = self.class._wp_srdb_database(base_srdb_options.merge(search_url: search_regex, replace_url: replace_regex, is_regex: true))

    # third pass for localdev: https://localdev_host with http://localdev_host
    if(self.location == LOCALDEV)
      search_url = "https://#{self.replace_host}"
      replace_url = "http://#{self.replace_host}"
      pass_three = self.class._wp_srdb_database(base_srdb_options.merge(search_url: search_url, replace_url: replace_url, is_regex: false))
    end
    finished = Time.now

    rewrite_results = {:pass_one => pass_one, :pass_two => pass_two}
    rewrite_results.merge(:pass_three => pass_three) if pass_three

    rewrite_log = self.app_url_rewrite_logs.create(started_at: started, finished_at: finished, runtime: finished - started, results: rewrite_results)

    return true
  end

  def self.rewrite_wordpress_urls_for_app_and_location(application,location,debug_srdb=false)
    all_rewrites = self.where(application_id: application.id).where(location: location)
    all_rewrites.each do |rewrite|
      rewrite.rewrite_wordpress_urls(debug_srdb)
    end
  end

  def self._wp_srdb_database(options)
    command_array = []
    command_array << "#{Settings.data_dump_php_cmd} -d memory_limit=512M #{Rails.root}/script/srdb/srdb.cli.php"
    command_array << "--user=#{options[:user]}"
    command_array << "--pass=#{options[:pass]}"
    command_array << "--host=#{options[:host]} --port=#{options[:port]}"
    command_array << "--name=#{options[:dbname]}"
    command_array << "--search=#{options[:search_url]}"
    command_array << "--replace=#{options[:replace_url]}"
    if(options[:is_regex])
      command_array << "--regex"
    end
    if(!options[:debug])
      command_array << "--verbose=false"
    end
    command = command_array.join(' ')
    run_command(command,options[:debug])
  end

end
