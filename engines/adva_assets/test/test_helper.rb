require File.expand_path(File.dirname(__FILE__) + '/../../adva_cms/test/test_helper')

Dir[File.dirname(__FILE__) + "/test_helper/**/*.rb"].each { |path| require path }

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) +  '/test_helper/fixtures'