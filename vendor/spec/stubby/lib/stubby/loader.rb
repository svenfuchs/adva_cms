module Stubby
  module Loader
    class << self
      def scenario(name, &block)
        Stubby.scenarios[name] = block
      end
      
      def define(original_class, &block)
        definition = Definition.new :original_class => original_class
        definition.create! &block
      end
    
      def load
        unless @loaded
          Dir["#{Stubby.directory}/*"].each do |filename|
            instance_eval IO.read(filename), filename
          end
        end
        @loaded = true
      end 
    end
  end
end