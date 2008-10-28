# does not include environment.rb

unless defined?(RAILS_ROOT) # environment.rb included?
  require File.expand_path(File.dirname(__FILE__) + '/mock_rails')
  require File.expand_path(File.dirname(__FILE__) + '/mock_models')
end

require File.expand_path(File.dirname(__FILE__) + '/spec_roles_helper')
