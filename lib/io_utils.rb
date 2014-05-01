# === COPYRIGHT:
# Copyright (c) 2014 North Carolina State University
# === LICENSE:
# see LICENSE file
module IoUtils


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
  
end
