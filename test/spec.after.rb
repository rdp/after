require 'spec/autorun'
require 'sane'
require_rel './after'

describe After do

  it "should be able to grab the right pid" do
     pid = Process.spawn "ruby ./sleep_10.rb"
     sleep 0.01
     a = After.find_pid('sleep_10')
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