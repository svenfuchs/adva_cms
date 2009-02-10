require 'test/unit'
require File.dirname(__FILE__) + '/test_helper.rb'
require 'test_server/server'

class ServerTest < Test::Unit::TestCase
  def setup
    @runner = stub(:run => nil)
    @rails = stub(:reload_application => nil, :cleanup_application => nil)
    @server = TestServer::Server.new
    @server.stubs(:rails).returns @rails
  end
  
  
  def test_parse_opts_recognizes_daemon_and_pid_argvs
    argv = ["--daemon", "--pid=1"]
    expected = { :daemon => true, :pid => '1' }
    assert_equal expected, @server.send(:parse_opts, argv)
  end
  
  def test_run_calls_callbacks
    @server.expects(:run_callbacks).with(:before_run)
    @server.expects(:run_callbacks).with(:after_run)
    @server.run ARGV, STDERR, STDOUT, :runner => @runner
  end

  # no idea how to test Process.fork, DRb.thread.join and stuff like that :/
end