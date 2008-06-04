require "rubygems"
require "test/unit"
require "spec"
require "json"
require "rr"
require "tmpdir"
require "fileutils"
require "active_support"
require "action_controller"
require "action_controller/test_process"

dir = File.dirname(__FILE__)
$LOAD_PATH << "#{dir}/../lib"
require "cacheable_flash"
require "cacheable_flash/test_helpers"

Spec::Runner.configure do |config|
  config.mock_with :rr
end
class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end