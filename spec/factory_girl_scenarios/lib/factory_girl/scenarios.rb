class Factory
  mattr_reader :scenarios
  @@scenarios = {}
  
  class << self
    def define_scenario(name, &block)
      scenarios[name] = block
    end
  end
end

module FactoryScenario
  def factory_scenario(*names)
    names.each do |name|
      if scenario = Factory.scenarios[name]
        instance_eval &scenario
      else
        raise "scenario #{name.inspect} not defined"
      end
    end
  end
end