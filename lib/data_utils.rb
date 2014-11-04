# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
module DataUtils


  def dump_database_to_file(database, fromhost, outputfile, debug=false)
    if(fromhost == 'development')
      host_command = "--host=#{Settings.data_dump_mysql_host_development}"
    elsif(fromhost == 'scrubbed')
      host_command = "--socket=#{Settings.data_dump_mysql_socket}"
    else
      # production replica
      host_command = "--host=#{Settings.data_dump_mysql_host_production_replica}"
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
    if(fromhost == 'development')
      host_command = "--host=#{Settings.data_dump_mysql_host_development}"
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

  def wp_srdb_database(database,search_host,replace_host,debug)
    command_array = []
    command_array << "#{Settings.data_dump_php_cmd} #{Rails.root}/script/srdb/srdb.cli.php"
    command_array << "--user=#{Settings.data_dump_mysql_user}"
    command_array << "--pass=#{Settings.data_dump_mysql_pass}"
    command_array << "--host=#{Settings.data_dump_mysql_host_scrubbed}"
    command_array << "--port=#{Settings.data_dump_mysql_port}"
    command_array << "--name=#{database}"
    command_array << "--search=#{search_host}"
    command_array << "--replace=#{replace_host}"
    # if(debug)
    #   command_array << "--verbose"
    # end
    command = command_array.join(' ')
    run_command(command,debug)
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
