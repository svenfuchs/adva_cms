module RoutingFilter
  class Base
    class_inheritable_accessor :active
    self.active = true

    attr_accessor :successor, :options

    def initialize(options = {})
      @options = options
      options.each { |name, value| instance_variable_set :"@#{name}", value }
    end

    def run(method, *args, &block)
      successor = @successor ? lambda { @successor.run(method, *args, &block) } : block
      active ? send(method, *args, &successor) : successor.call(*args)
    end
  end
end