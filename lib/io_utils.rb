# === COPYRIGHT:
# Copyright (c) 2014 North Carolina State University
# === LICENSE:
# see LICENSE file
module IoUtils


  def run_command(command,debug = false)
    logger.debug "running #{command}" if debug
    stdin, stdout, stderr = Open3.popen3(command)
    # ignore stdout [Warning]
    stdout_results = stdout.readlines
    stderr_results = stderr.readlines
    # this is really a dumb idea to allow run_command to have
    # knowledge of a mysql warning at this level, but given
    # that mysql doesn't allow for suppressing the error
    # i guess we have to deal with it
    results = stdout_results + stderr_results
    results.each do |line|
      if(line =~ %r{Using a password})
        results.delete(line)
      end
    end
    return results.join('')
  end

  def capture_stderr &block
    real_stderr, $stderr = $stderr, StringIO.new
    yield
    $stderr.string
  ensure
    $stderr = real_stderr
  end

end
