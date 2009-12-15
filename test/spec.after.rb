require 'spec/autorun'
require 'sane'
require_rel './after'

describe After do

  it "should be able to grab the right pid" do
     io = IO.popen "ruby -e 'puts Process.pid; loop { puts }'" 
     # force it to output because I think...maybe the OS is buffering its output for us, so we don't see any without that?
     pid = io.readline
     a = After.find_pid('sleep 10')
     a.should == pid
  end


  it "should immediately return if the other process doesn't exist" do
    pending
  end

  it "should wait for another process to terminate" do
    pending
  end

  it "should warn if there are several available" do
    pending
  end

end