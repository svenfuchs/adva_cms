$:.reject!{ |e| e.include? 'TextMate' }

require "test/unit"

plugin_root = File.join(File.dirname(__FILE__), "..")
app_root = File.join(plugin_root, "..", "..", "..")

ENV["RAILS_ENV"] = "test"

# pull in some basic Rails bits, but not our whole app, yo
require File.expand_path(File.join(app_root, "config", "boot"))
$:.unshift(File.expand_path(File.join(plugin_root, "lib")))

# initialize the plugin
require plugin_root + "/init"

# pull in just what we need from Rails
%w( active_record active_support ).each { |f| require f }


# we'll use a totally standalone db for our testing
options = { :adapter => "sqlite3", :timeout => 500, :database => ":memory:" }

# establish the connection manually
ActiveRecord::Base.establish_connection(options)
  
# ...and provide some connection data so that fixtures will work
ActiveRecord::Base.configurations = { :sqlite3 => options }

# kickstart
ActiveRecord::Base.connection

# create our test schema
ActiveRecord::Migration.verbose = false
require File.expand_path(File.join(plugin_root, "test", "db", "schema"))

# pull in our test AR::B models
models = Dir.glob(File.join(plugin_root, "test", "app", "models", "*.rb"))
models.each { |m| require File.expand_path(m) }


# load the factories
require File.join( plugin_root, 'test', 'factories' )
