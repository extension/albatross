# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
module DataUtils


  def dump_database_to_file(database, outputfile, debug=false)
    command_array = []
    command_array << "#{Settings.data_dump_mysql_dump_cmd}"
    command_array << "--user=#{Settings.data_dump_mysql_user}"
    command_array << "--password=#{Settings.data_dump_mysql_pass}"
    command_array << "--socket=#{Settings.data_dump_mysql_socket}"
    command_array << "--extended-insert"
    command_array << "--no-autocommit"
    command_array << "#{database}"
    command_array << "> #{outputfile}"
    command = command_array.join(' ')
    run_command(command,debug)
  end

  def drop_database(database, debug=false)
    if(database =~ %r{^scrubbed})
      command_array = []
      command_array << "#{Settings.data_dump_mysql_cmd}"
      command_array << "--user=#{Settings.data_dump_mysql_user}"
      command_array << "--password=#{Settings.data_dump_mysql_pass}"
      command_array << "--socket=#{Settings.data_dump_mysql_socket}"
      command_array << "-e \"DROP DATABASE IF EXISTS #{database}\""
      command = command_array.join(' ')
      run_command(command,debug)
    end
  end

  def create_database(database, debug=false)
    if(database =~ %r{^scrubbed})
      command_array = []
      command_array << "#{Settings.data_dump_mysql_cmd}"
      command_array << "--user=#{Settings.data_dump_mysql_user}"
      command_array << "--password=#{Settings.data_dump_mysql_pass}"
      command_array << "--socket=#{Settings.data_dump_mysql_socket}"
      command_array << "-e \"CREATE DATABASE IF NOT EXISTS #{database}\""
      command = command_array.join(' ')
      run_command(command,debug)
    end
  end

  def import_database_from_file(database,inputfile, debug=false)
    command_array = []
    command_array << "#{Settings.data_dump_mysql_cmd}"
    command_array << "--user=#{Settings.data_dump_mysql_user}"
    command_array << "--password=#{Settings.data_dump_mysql_pass}"
    command_array << "--socket=#{Settings.data_dump_mysql_socket}"
    command_array << "#{database}"
    command_array << "< #{inputfile}"
    command = command_array.join(' ')
    run_command(command,debug)
  end

  def import_database_to_master_server_from_file(database,inputfile, debug=false)
    command_array = []
    command_array << "#{Settings.data_dump_mysql_cmd}"
    command_array << "--user=#{Settings.data_dump_mysql_user}"
    command_array << "--password=#{Settings.data_dump_mysql_pass}"
    command_array << "--host=#{Settings.data_dump_mysql_master_server}"
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
      column = scrubbers[table]['column']
      value = scrubbers[table]['value']
      scrub_query = "\"UPDATE #{table} SET #{column}='#{value}';\""
      command = "#{base_command} -e #{scrub_query}"
      run_command(command,debug)
    end
  end


  def run_command(command,debug = false)
    logger.debug "running #{command}" if debug
    stdin, stdout, stderr = Open3.popen3(command)
    results = stdout.readlines + stderr.readlines
    return results.join('')
  end

  def capture_stderr &block
    real_stderr, $stderr = $stderr, StringIO.new
    yield
    $stderr.string
  ensure
    $stderr = real_stderr
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