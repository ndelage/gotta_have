module GottaHave
  module CmdLineHelpers
    require 'open4'
    # 1 SIGHUP  Clean tidyup
    # 2 SIGINT  Interrupt
    # 3 SIGQUIT Quit
    # 6 SIGABRT Abort
    # 15  SIGTERM Terminate
    SHELL_SIGNAL_TRAPPING = "trap '' 1 2 3 6 15;"

    # general util for command line execution and checking of status
    def self.execute_command( cmd_string, context, acceptable_exit_status_codes=[], trap_signals=true)
      result = nil
      error = ""

      # We always force 0 to be an acceptable exit status code
      acceptable_exit_status_codes << 0

      cmd_string = SHELL_SIGNAL_TRAPPING + " " + cmd_string if trap_signals
      status = Open4::popen4( cmd_string) do |pid, stdin, stdout, stderr|
        result = stdout.read if stdout
        error = stderr.read if stderr
      end

      unless acceptable_exit_status_codes.include?( status.exitstatus )
        raise "#{context}: error: #{error}"
      end

      result
    end

  end

end
