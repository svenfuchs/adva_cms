# does not include environment.rb

$:.unshift File.expand_path(File.dirname(__FILE__) + "/../../../plugins/rspec/lib")
require 'active_support'
require 'spec'

module ActiveRecord; class Base; end; end

plugin_dir = File.expand_path(File.dirname(__FILE__) + '/../')
$:.unshift plugin_dir + "/lib"
require plugin_dir + '/init.rb'

