module HasOptions  
  class << self
    def included(base)
      base.class_eval do
        extend ClassMethods
        class_inheritable_accessor :option_definitions
        serialize :options        
      end
    end
    
    def option(*args)
      include HasOptions unless included_modules.include? HasOptions
      option *args
    end
  end
  
  module ClassMethods    
    def option(name, definition = {})
      self.option_definitions ||= {}
      self.option_definitions[name] = definition.reverse_update(:default => nil, :type => :text_field)
      class_eval %Q(
        def #{name}
          self.options ||= {}
          options[:#{name}] || option_definitions[:#{name}][:default]
        end                
        def #{name}=(value)
          self.options ||= {}
          options[:#{name}] = value
        end
      ), __FILE__, __LINE__
    end
  end
end

ActiveRecord::Base.send :include, HasOptions