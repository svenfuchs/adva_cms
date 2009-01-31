$:.push File.expand_path(File.dirname(__FILE__) + '/../../with/lib')
$:.push File.expand_path(File.dirname(__FILE__) + '/../lib')

# require 'actionpack'
# require 'action_controller'
# require 'action_controller/test_process'
# require 'active_support'

module ActionController
  class TestCase < Test::Unit::TestCase
    # Sucky.
    # Placeholder so test/unit ignores test cases without any tests.
    def default_test
    end
  end
end

require 'with'
require 'with-sugar/view'