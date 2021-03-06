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
      host_command = "--host=#{Settings.data_dump_mysql_host_scrubbed} --port=#{Settings.data_dump_mysql_host_scrubbed_port}"
    else
      return 'invalid export host'
    end
    command_array = []
    command_array << "#{Settings.data_dump_mysql_dump_cmd}"
    if(fromhost == 'scrubbed')
      command_array << "--user=#{Settings.data_mysql_scrub_user}"
      command_array << "--password=#{Settings.data_mysql_scrub_pass}"
    else
      command_array << "--user=#{Settings.data_mysql_albatross_user}"
      command_array << "--password=#{Settings.data_mysql_albatross_pass}"
    end
    command_array << host_command
    command_array << "--extended-insert"
    command_array << "--no-autocommit"
    command_array << "--set-gtid-purged=OFF"
    command_array << "#{database}"
    command_array << "> #{outputfile}"
    command = command_array.join(' ')
    run_command(command,debug)
  end

  def drop_scrubbed_database(database, debug=false)
    command_array = []
    command_array << "#{Settings.data_dump_mysql_cmd}"
    command_array << "--user=#{Settings.data_mysql_scrub_user}"
    command_array << "--password=#{Settings.data_mysql_scrub_pass}"
    command_array << "--host=#{Settings.data_dump_mysql_host_scrubbed} --port=#{Settings.data_dump_mysql_host_scrubbed_port}"
    command_array << "-e \"DROP DATABASE IF EXISTS #{database}\""
    command = command_array.join(' ')
    run_command(command,debug)
  end

  def create_scrubbed_database(database, debug=false)
    command_array = []
    command_array << "#{Settings.data_dump_mysql_cmd}"
    command_array << "--user=#{Settings.data_mysql_scrub_user}"
    command_array << "--password=#{Settings.data_mysql_scrub_pass}"
    command_array << "--host=#{Settings.data_dump_mysql_host_scrubbed} --port=#{Settings.data_dump_mysql_host_scrubbed_port}"
    command_array << "-e \"CREATE DATABASE IF NOT EXISTS #{database}\""
    command = command_array.join(' ')
    run_command(command,debug)
  end

  def import_database_from_file(database,fromhost,inputfile, debug=false)
    if(fromhost == 'dev-aws')
      host_command = "--host=#{Settings.data_dump_mysql_host_aws_dev} --port=#{Settings.data_dump_mysql_host_aws_dev_port}"
    elsif(fromhost == 'scrubbed')
      host_command = "--host=#{Settings.data_dump_mysql_host_scrubbed} --port=#{Settings.data_dump_mysql_host_scrubbed_port}"
    else
      return 'invalid import host'
    end
    command_array = []
    command_array << "#{Settings.data_dump_mysql_cmd}"
    if(fromhost == 'scrubbed')
      command_array << "--user=#{Settings.data_mysql_scrub_user}"
      command_array << "--password=#{Settings.data_mysql_scrub_pass}"
    else
      command_array << "--user=#{Settings.data_mysql_albatross_user}"
      command_array << "--password=#{Settings.data_mysql_albatross_pass}"
    end
    command_array << host_command
    command_array << "#{database}"
    command_array << "< #{inputfile}"
    command = command_array.join(' ')
    run_command(command,debug)
  end

  def drop_tables_from_staging_database(database)
    connection_settings = {}
    connection_settings[:username] = Settings.data_mysql_albatross_user
    connection_settings[:password] = Settings.data_mysql_albatross_pass
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
    base_command_array << "--user=#{Settings.data_mysql_scrub_user}"
    base_command_array << "--password=#{Settings.data_mysql_scrub_pass}"
    base_command_array << "--host=#{Settings.data_dump_mysql_host_scrubbed} --port=#{Settings.data_dump_mysql_host_scrubbed_port}"
    base_command_array << "--database=#{database}"
    base_command = base_command_array.join(' ')

    scrubbers.keys.each do |table|
      if(scrubbers[table]['columns'] and scrubbers[table]['columns'].is_a?(Hash))
        setters = []
        scrubbers[table]['columns'].each do |column,value|
          setters << "#{column} = \"#{value}\""
        end
        scrub_query = "'UPDATE #{table} SET #{setters.join(', ')};'"
      elsif(scrubbers[table]['column'] and scrubbers[table]['value'])
        column = scrubbers[table]['column']
        value = scrubbers[table]['value']
        scrub_query = "'UPDATE #{table} SET #{column}=\"#{value}\";'"
      end

      if(scrub_query)
        command = "#{base_command} -e #{scrub_query}"
        run_command(command,debug)
      end
    end
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
