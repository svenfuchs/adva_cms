require 'test_server/server'

TestServer::Server.before_run do
  With.options[:line] = nil
  OptionParser.new do |o|
    o.on('-l', '--line=LINE') { |line| With.options[:line] = line }
  end.parse!(argv)
  
  blueprints = Dir[File.dirname(__FILE__) + "/../blueprints/**/*.rb"]
  blueprints.each{|path| load path }
end

TestServer::Server.after_run do
  With.reset_all
end