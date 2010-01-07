require 'ruby-wmi' # wow not even pretended linux compat. yet
require 'sane'
require 'wait_pid'

class After

  def self.find_pids(many_args)
    procs = WMI::Win32_Process.find(:all)
    #_dbg
    pids = []
    for proc in procs # TODO respect proc.Name!
      if proc.CommandLine && proc.CommandLine.contain?(many_args)
      	#if (proc.CommandLine && proc.CommandLine.contain?(many_args)) || proc.Name.include?(many_args)
        pid = proc.ProcessId.to_i
        next if pid == Process.pid
        pids << pid
        if $VERBOSE
         print 'adding ', proc.ProcessId, ' ', proc.Name, ' ', proc.CommandLine, "\n"
        end
      end
    end
    pids
  end

  def self.find_and_wait_for(args)
   pids = find_pids args
   if pids.length > 1
     puts "found more than one -- waiting for all #{pids.inspect}"
   end
   pids.each{|pid| 
     puts "waiting for #{pid}"
     WaitPid.wait_nonchild_pid pid 
   }
  end
  
  def self.wait_pid pid
    WaitPid.wait_nonchild_pid pid
  end

end