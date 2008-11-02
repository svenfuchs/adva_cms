%w(controller_example_group_methods model_example_group_methods).each { |lib| require "rspec_on_rails_on_crack/#{lib}" }

begin
  require 'ruby2ruby'
rescue LoadError
  # no pretty example descriptions for you
end

class ActionController::TestSession
  def include?(key)
    data.include?(key)
  end
end

Spec::Rails::Example::ControllerExampleGroup.extend RspecOnRailsOnCrack::ControllerExampleGroupMethods
Spec::Rails::Example::ModelExampleGroup.extend RspecOnRailsOnCrack::ModelExampleGroupMethods