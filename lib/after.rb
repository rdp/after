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
        procs_by_pid[proc.ProcessId] = ("% 20s" % proc.Name.to_s) + ' ' + proc.CommandLine.to_s
      end
    else
      a = `ps -ef` # my linux support isn't very good yet...
      a.lines.to_a[1..-1].each{|l| pid = l.split(/\s+/)[1]; procs_by_pid[pid.to_i] = l}
    end

    good_pids = []
    for pid, description in procs_by_pid
      if description.contain?(many_args)
        next if pid == Process.pid
        good_pids << [pid, description]
        if $DISPLAY_ALL
         pps 'found', "% 5d" % pid, description
        end
      end
    end
    good_pids
  end

  def self.find_and_wait_for(args)
    pids = find_pids args
    if pids.length > 1
      puts "found more than one -- waiting for all -- #{pids.map{|pid, name| name}.inspect}" if $VERBOSE
    end
    pids.each{|pid, name|
      puts "waiting for #{pid} (#{name.strip})" if $VERBOSE
      WaitPid.wait_nonchild_pid pid
    }
  end

  def self.wait_pid pid
    WaitPid.wait_nonchild_pid pid
  end


  # main, really
  def self.go
    if ARGV.delete('-q')
      $VERBOSE = false
    else
      $VERBOSE = true
    end

    $DISPLAY_ALL = false
    if ARGV[0].in? ['-l', '--list']
      ARGV.shift
      $DISPLAY_ALL = true
      query = ARGV.shift || ''
      got = After.find_pids(query)
      if got.empty?
        puts "none found #{query}"
      end
      exit # early exit
    elsif ARGV[0] == '-p'
      ARGV.shift
      pids = ARGV.shift
      pids = pids.split(',')
      puts "waiting for pids #{pids.join(',')}" if $VERBOSE and pids.length > 1
      for pid in pids.split(',')
        puts "waiting for pid #{pid}" if $VERBOSE
        begin
          After.wait_pid pid.to_i
        rescue Errno::EPERM
          p 'pid does not exist maybe it already had exited ' + pid if $VERBOSE
        end
      end
    else
      After.find_and_wait_for(ARGV.shift)
    end

    puts 'after: now running:', ARGV if $VERBOSE
    system(*ARGV) if ARGV.length > 0
  end

end
