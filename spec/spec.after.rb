require 'spec/autorun'
require 'sane'
require_relative '../lib/after'

describe After do

  def go how_many = 1
     pid = Process.spawn "ruby ./sleep.rb #{how_many}"
     Thread.new { Process.wait pid } # wait for it, so we can collect child processes, too
     pid
  end

  it "should be able to grab the right pid" do
     pid = go
     a = After.find_pids('sleep')
     a[0].should == pid
  end

  it "should immediately return if the other process doesn't exist" do
    a = After.find_pids('non existent process')
    assert a.empty?
  end

  it "should wait for another process to terminate" do
    go
    start = Time.now
    After.find_and_wait_for('sleep')
    assert (Time.now - start) > 0.5 
  end

  it "should work if there are several available" do
    go 1
    go 2
    go 3
    start = Time.now
    After.find_and_wait_for('sleep')
    assert (Time.now - start) > 2     
  end

  it "should not return the PID of this process" do
    a = After.find_pids('ruby')
    assert !Process.pid.in?(a)
  end

  it "should allow for passing in a pid" do
   pid = go 1
   After.wait_pid pid 
  end

  it "should find .bat filenames" do
    # unfortunately I don't know how to query for exact parameters, though...
     pid = Process.spawn "cmd /c sleep.bat 1"
     Thread.new { Process.wait pid } # wait for it, so we can collect child processes, too
     a = After.find_pids('sleep.bat')
     assert a.length == 1
  end    	
  
  
  it "should find .bat filenames when run by selves" do
    # unfortunately I don't know how to query for exact parameters, though...
     pid = Process.spawn "sleep.bat 1"
     Thread.new { Process.wait pid } # wait for it, so we can collect child processes, too
     a = After.find_pids('sleep.bat')
     assert a.length == 1
  end    	


  it "should split the commands up right and across name, too"

end