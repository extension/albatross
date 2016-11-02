# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
module DataUtils


  def dump_database_to_file(database, fromhost, outputfile, debug=false)
    if(fromhost == 'dev-aws')
      host_command = "--host=#{Settings.data_dump_mysql_host_aws_dev} --port=#{Settings.data_dump_mysql_host_aws_dev_port}"
    elsif(fromhost == 'prod-aws')
      host_command = "--host=#{Settings.data_dump_mysql_host_aws_prod} --port=#{Settings.data_dump_mysql_host_aws_prod_port}"
    elsif(fromhost == 'scrubbed')
      host_command = "--socket=#{Settings.data_dump_mysql_socket}"
    else
      return 'invalid export host'
    end
    command_array = []
    command_array << "#{Settings.data_dump_mysql_dump_cmd}"
    command_array << "--user=#{Settings.data_dump_mysql_user}"
    command_array << "--password=#{Settings.data_dump_mysql_pass}"
    command_array << host_command
    command_array << "--extended-insert"
    command_array << "--no-autocommit"
    command_array << "#{database}"
    command_array << "> #{outputfile}"
    command = command_array.join(' ')
    run_command(command,debug)
  end

  def drop_scrubbed_database(database, debug=false)
    command_array = []
    command_array << "#{Settings.data_dump_mysql_cmd}"
    command_array << "--user=#{Settings.data_dump_mysql_user}"
    command_array << "--password=#{Settings.data_dump_mysql_pass}"
    command_array << "--socket=#{Settings.data_dump_mysql_socket}"
    command_array << "-e \"DROP DATABASE IF EXISTS #{database}\""
    command = command_array.join(' ')
    run_command(command,debug)
  end

  def create_scrubbed_database(database, debug=false)
    command_array = []
    command_array << "#{Settings.data_dump_mysql_cmd}"
    command_array << "--user=#{Settings.data_dump_mysql_user}"
    command_array << "--password=#{Settings.data_dump_mysql_pass}"
    command_array << "--socket=#{Settings.data_dump_mysql_socket}"
    command_array << "-e \"CREATE DATABASE IF NOT EXISTS #{database}\""
    command = command_array.join(' ')
    run_command(command,debug)
  end

  def import_database_from_file(database,fromhost,inputfile, debug=false)
    if(fromhost == 'dev-aws')
      host_command = "--host=#{Settings.data_dump_mysql_host_aws_dev} --port=#{Settings.data_dump_mysql_host_aws_dev_port}"
    elsif(fromhost == 'scrubbed')
      host_command = "--socket=#{Settings.data_dump_mysql_socket}"
    else
      return 'invalid import host'
    end
    command_array = []
    command_array << "#{Settings.data_dump_mysql_cmd}"
    command_array << "--user=#{Settings.data_dump_mysql_user}"
    command_array << "--password=#{Settings.data_dump_mysql_pass}"
    command_array << host_command
    command_array << "#{database}"
    command_array << "< #{inputfile}"
    command = command_array.join(' ')
    run_command(command,debug)
  end

  def drop_tables_from_staging_database(database)
    connection_settings = {}
    connection_settings[:username] = Settings.data_dump_mysql_user
    connection_settings[:password] = Settings.data_dump_mysql_pass
    connection_settings[:port] = Settings.data_dump_mysql_host_aws_dev_port
    connection_settings[:host] = Settings.data_dump_mysql_host_aws_dev

    connection_settings[:encoding] = "utf8"
    client = Mysql2::Client.new(connection_settings)
    result = client.query("SHOW TABLES FROM #{database}")
    tables = []
    result.each do |table_hash|
      tables += table_hash.values
    end
    result = client.query("USE #{database};")
    tables.each do |table|
      result = client.query("DROP table #{table};")
    end
    true
  end

  def scrub_database(database,scrubbers,debug)
    base_command_array = []
    base_command_array << "#{Settings.data_dump_mysql_cmd}"
    base_command_array << "--user=#{Settings.data_dump_mysql_user}"
    base_command_array << "--password=#{Settings.data_dump_mysql_pass}"
    base_command_array << "--socket=#{Settings.data_dump_mysql_socket}"
    base_command_array << "--database=#{database}"
    base_command = base_command_array.join(' ')

    scrubbers.keys.each do |table|
      if(scrubbers[table]['columns'] and scrubbers[table]['columns'].is_a?(Hash))
        setters = []
        scrubbers[table]['columns'].each do |column,value|
          setters << "#{column} = '#{value}'"
        end
        scrub_query = "\"UPDATE #{table} SET #{setters.join(', ')};\""
      elsif(scrubbers[table]['column'] and scrubbers[table]['value'])
        column = scrubbers[table]['column']
        value = scrubbers[table]['value']
        scrub_query = "\"UPDATE #{table} SET #{column}='#{value}';\""
      end

      if(scrub_query)
        command = "#{base_command} -e #{scrub_query}"
        run_command(command,debug)
      end
    end
  end

  def wp_srdb_database(database,fromhost,search_url,replace_url,is_regex,debug)
    if(fromhost == 'dev-aws')
      host = Settings.data_dump_mysql_host_aws_dev
      port = Settings.data_dump_mysql_host_aws_dev_port
    elsif(fromhost == 'scrubbed')
      host = '127.0.0.1'
      port = '3306'
    else
      return 'invalid import host'
    end

    srdb_options = {}
    srdb_options[:database] = database
    srdb_options[:host] = host
    srdb_options[:port] = port
    srdb_options[:user] = Settings.data_dump_mysql_user
    srdb_options[:pass] = Settings.data_dump_mysql_pass
    srdb_options[:search_url] = search_url
    srdb_options[:replace_url] = replace_url
    srdb_options[:is_regex] = is_regex
    srdb_options[:debug] = debug
    self._wp_srdb_database(srdb_options)

  end

  def _wp_srdb_database(options)

    command_array = []
    command_array << "#{Settings.data_dump_php_cmd} #{Rails.root}/script/srdb/srdb.cli.php"
    command_array << "--user=#{options[:user]}"
    command_array << "--pass=#{options[:pass]}"
    command_array << "--host=#{options[:host]} --port=#{options[:port]}"
    command_array << "--name=#{options[:database]}"
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


  # code from: https://github.com/ripienaar/mysql-dump-split
  def humanize_bytes(bytes)
    if(!bytes.nil? and bytes != 0)
      units = %w{B KB MB GB TB}
      e = (Math.log(bytes)/Math.log(1024)).floor
      s = "%.1f"%(bytes.to_f/1024**e)
      s.sub(/\.?0*$/,units[e])
    end
  end

end
