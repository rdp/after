require 'ruby-wmi' # wow not even pretended linux compat. yet
require 'sane'
require 'andand'
require 'wait_pid'

class After

  def self.find_pids(many_args)

    procs = WMI::Win32_Process.find(:all)
    pids = []
    for proc in procs # TODO respect proc.Name!
      if proc.CommandLine.andand.contain?(many_args)
        pids << proc.ProcessId.to_i
        if $VERBOSE
         print 'adding ', proc.ProcessId, ' ', proc.Name, ' ', proc.CommandLine, "\n"
        end
      end
    end
    pids.reject{|pid| pid == Process.pid} # don't want ours...
  end

  def self.find_and_wait_for(args)
   pids = find_pids args
   pids.each{|pid| WaitPid.wait_nonchild_pid pid }
  end

end