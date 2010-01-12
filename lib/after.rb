require 'os'
if OS.windows?
  require 'ruby-wmi' # wow not even pretended linux compat. yet
end
require 'sane'
require 'wait_pid'

class After

  def self.find_pids(many_args)

    procs_by_pid = {}
    if OS.windows?
      procs = WMI::Win32_Process.find(:all)
      for proc in procs
        procs_by_pid[proc.ProcessId] = proc.CommandLine.to_s + proc.Name.to_s
      end
    else
      a = `ps -ef`
      a.lines.to_a[1..-1].each{|l| pid = l.split(/\s+/)[1]; procs_by_pid[pid.to_i] = l}
    end

    good_pids = []
    for pid, description in procs_by_pid
      if description.contain?(many_args)
        next if pid == Process.pid
        good_pids << pid
        if $VERBOSE
         pps 'adding', pid, description
        end
      end
    end
    good_pids
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
