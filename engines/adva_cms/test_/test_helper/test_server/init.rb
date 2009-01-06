require 'test_server/server'

TestServer::Server.before_run do
  blueprints = Dir[File.dirname(__FILE__) + "/../blueprints/**/*.rb"]
  blueprints.each{|path| load path }
end

TestServer::Server.after_run do
  # With.reset
end