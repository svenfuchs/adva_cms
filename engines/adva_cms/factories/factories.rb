$:.push File.expand_path(RAILS_ROOT + '/vendor/gems/thoughtbot-factory_girl-1.1.3/lib')
require 'factory_girl'
require 'factory_girl/scenarios'
include FactoryScenario

Spec::Example::ExampleGroup.send :include, FactoryScenario if defined? Spec

# load factories
dir = File.dirname(__FILE__) + '/factories'
Dir[dir + '/**/*.rb'].sort.each{|path| require path }

# load scenarios
dir = File.dirname(__FILE__) + '/scenarios'
Dir[dir + '/**/*.rb'].sort.each{|path| require path }

