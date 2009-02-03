# http://coderrr.wordpress.com/2008/04/22/building-the-right-class-with-sti-in-rails/

module ActiveRecord::StiInstantiation
  module ActMacro
    def instantiates_with_sti
      include InstanceMethods
      extend ClassMethods
      instantiates_with_sti?
    end

    def instantiates_with_sti?
      included_modules.include?(ActiveRecord::StiInstantiation::InstanceMethods)
    end
  end

  module InstanceMethods
  end

  module ClassMethods
    def new(*args, &block)
      options = args.first.is_a?(Hash) ? args.first : {}
      type = options[:type] || options['type']
      klass = type.is_a?(Class) ? type : type.constantize if type

      if type and klass != self
        raise "STI instantiation error: class #{klass.name} should be a descendant of #{self.name}" unless klass < self
        klass.new(*args, &block)
      else
        super
      end
    end
  end
end

ActiveRecord::Base.send :extend, ActiveRecord::StiInstantiation::ActMacro
