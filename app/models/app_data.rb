# === COPYRIGHT:
# Copyright (c) 2012 North Carolina State University
# === LICENSE:
# see LICENSE file
require 'fileutils'

class AppData < ActiveRecord::Base
  serialize :scrubbers
  belongs_to :application


  def dump(debug=false)
    # bail if the backup dir doesn't exist
    if(!File.exists?(Settings.data_dump_dir_dump))
      return {success: false, error: "#{Settings.data_dump_dir_dump} does not exist"}
    end

    if(self.scrub?)
      scrubbed_dump(debug)
    else
      normal_dump(debug)
    end
  end

  def normal_dump(debug = false)

    target_file = "#{Settings.data_dump_dir_dump}/#{self.dbname}.sql"
    tmp_dump_file =  "#{target_file}.tmp"

    result = self.class.dump_database_to_file(self.dbname,tmp_dump_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # compress it
    gzip_command = "#{Settings.data_dump_gzip_cmd} #{tmp_dump_file}"
    result = self.class.run_command(gzip_command,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end


    # move it
    move_source = "#{tmp_dump_file}.gz"
    move_target = "#{target_file}.gz"

    begin
      FileUtils.mv(move_source,move_target,force: true)
    rescue Exception => e
      return {success: false, error: e}
    end

    self.update_attribute(:last_dumped_at, Time.now)
    {success: true, file: "#{target_file}.gz"}
  end

  def scrubbed_dump(debug = false)
    target_file = "#{Settings.data_dump_dir_dump}/#{self.dbname}_scrubbed.sql"
    tmp_dump_file =  "#{target_file}.tmp"
    pre_scrubbed_file = "#{Settings.data_dump_dir_dump}/#{self.dbname}.sql.pre_scrubbed"
    scrubbed_database = "scrubbed_#{self.dbname}"

    # dump
    result = self.class.dump_database_to_file(self.dbname,pre_scrubbed_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # drop
    self.class.drop_database(scrubbed_database,debug)
    self.class.create_database(scrubbed_database,debug)

    # import
    result = self.class.import_database_from_file(scrubbed_database,pre_scrubbed_file,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # unlink
    File.delete(pre_scrubbed_file)

    # scrub
    self.class.scrub_database(scrubbed_database,self.scrubbers,debug)

    # dump
    result = self.class.dump_database_to_file(scrubbed_database,tmp_dump_file,debug)

    # compress it
    gzip_command = "#{Settings.data_dump_gzip_cmd} #{tmp_dump_file}"
    result = self.class.run_command(gzip_command,debug)
    if(!result.blank?)
      return {success: false, error: "#{result}"}
    end

    # move it
    move_source = "#{tmp_dump_file}.gz"
    move_target = "#{target_file}.gz"

    begin
      FileUtils.mv(move_source,move_target,force: true)
    rescue Exception => e
      return {success: false, error: e}
    end

    # drop
    self.class.drop_database(scrubbed_database,debug)

    {success: true, file: "#{target_file}.gz"}

  end

  def self.dump_database_to_file(database, outputfile, debug=false)
    command_array = []
    command_array << "#{Settings.data_dump_mysql_dump_cmd}"
    command_array << "--user=#{Settings.data_dump_mysql_user}"
    command_array << "--password=#{Settings.data_dump_mysql_pass}"
    command_array << "--socket=#{Settings.data_dump_mysql_socket}"
    command_array << "#{database}"
    command_array << "> #{outputfile}"
    command = command_array.join(' ')
    result = run_command(command,debug)
  end

  def self.drop_database(database, debug=false)
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

  def self.create_database(database, debug=false)
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

  def self.import_database_from_file(database,inputfile, debug=false)
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

  def self.scrub_database(database,scrubbers,debug)
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


  def self.run_command(command,debug = false)
    logger.debug "running #{command}" if debug
    cmdoutput =  %x{#{command}}
    return cmdoutput
  end

end
