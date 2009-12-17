require 'ruby-wmi'
require 'sane'
require 'andand'
require 'win32/process' # waitpid for doze

class After

  def self.find_pids(many_args)

    procs = WMI::Win32_Process.find(:all)
    pids = []
    for proc in procs
      if proc.CommandLine.andand.contain? many_args
        pids << proc.ProcessId.to_i
      end
    end
    pids
  end

  def self.find_and_wait_for(args)
   pids = find_pids args
   pids.each{|pid| Process.waitpid pid}
  end

end