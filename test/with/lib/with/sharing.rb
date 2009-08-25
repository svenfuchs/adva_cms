module With
  module Sharing
    def share(group, name = nil, &block)
      context = Context.new(name || group, &block)
      context.instance_eval &block if block
      
      self.shared[group] ||= []
      self.shared[group] << context
    end
    
    def shared(name = nil)
      @@shared ||= {}
      name.nil? ? @@shared : begin
        raise "could not find shared context #{name.inspect}" unless @@shared.has_key?(name)
        @@shared[name].map {|context| context.clone }
      end
    end

    def share_condition(name, &block)
      @@conditions ||= {}
      @@conditions[name] = block
    end
    
    def condition(name)
      @@conditions ||= {}
      @@conditions[name]
    end
  end
end