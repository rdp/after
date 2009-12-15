require 'ruby-wmi'

class After


  def self.find_pid(many_args)

    procs = WMI::Win32_Process.find(:all)
    for proc in procs
      if proc.CommandLine.contain? many_args
        return proc.ProcessId.to_i
      end
    end

  end


end