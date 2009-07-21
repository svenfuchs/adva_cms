require 'rubygems'

$:.unshift File.expand_path(File.dirname(__FILE__) + "/../../../plugins/rspec/lib")
require 'active_support'
require 'active_record'
require 'spec'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/db/database.yml'))
config['test']['database'] = File.dirname(__FILE__) + "/#{config['test']['database']}"

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/log/debug.log")
ActiveRecord::Base.configurations = config
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false
  load(File.dirname(__FILE__) + "/db/schema.rb")
end

plugin_dir = File.expand_path(File.dirname(__FILE__) + '/../')
$:.unshift plugin_dir + "/lib"
require plugin_dir + '/init.rb'