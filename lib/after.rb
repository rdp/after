require 'ruby-wmi' # wow not even pretended linux compat. yet
require 'sane'
require 'wait_pid'

class After

  def self.find_pids(many_args)
    procs = WMI::Win32_Process.find(:all)
    #_dbg
    pids = []
    for proc in procs # TODO respect proc.Name!
      if (proc.CommandLine && proc.CommandLine.contain?(many_args)) || proc.Name.include?(many_args)
        pid = proc.ProcessId.to_i
        next if pid == Process.pid
        pids << [pid, proc.CommandLine]
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
      puts "found more than one -- waiting for all #{pids.map{|pid, name| name}.inspect}"
    end
    pids.each{|pid, name|
      puts "waiting for #{name} (#{pid})"
      WaitPid.wait_nonchild_pid pid
    }
  end

  def self.wait_pid pid
    WaitPid.wait_nonchild_pid pid
  end

  # main, really
  def self.go
    if ARGV[0] == '-v'
      ARGV.shift
      $VERBOSE = true
      puts 'running in verbose mode'
    end

    if ARGV[0] == '-l' || ARGV[0] == '--list'
      $VERBOSE = true # so it'll output the names...
      ARGV.shift
      After.find_pids(ARGV.shift)
      exit # premature exit
    elsif ARGV[0] == '-p'
      ARGV.shift
      pid = ARGV.shift
      After.wait_pid pid.to_i
    else
      After.find_and_wait_for(ARGV.shift)
    end

    puts 'running', ARGV if $VERBOSE
    system(*ARGV) if ARGV.length > 0
  end

end
