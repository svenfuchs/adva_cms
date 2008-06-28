module Stubby
  mattr_accessor :scenarios
  @@scenarios = {}
  
  def scenario(*names)
    names.each do |name|
      raise "scenario :#{name} is not defined" unless scenarios[name]
      instance_eval &scenarios[name]
    end
  end
  
  module Scenario
    mattr_accessor :directory
    
    module Loader
      class << self
        def scenario(name, &block)
          Stubby.scenarios[name] = block
        end
      
        def load
          unless @loaded
            Dir["#{Stubby::Scenario.directory}/**/*"].each do |filename|
              instance_eval IO.read(filename), filename
            end
          end
          @loaded = true
        end 
      end
    end
  end  
end