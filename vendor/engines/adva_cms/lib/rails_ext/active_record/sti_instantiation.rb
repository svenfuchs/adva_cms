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
    def new(*a, &b)
      if (h = a.first).is_a? Hash and (type = h[:type] || h['type']) and (klass = type.constantize) != self
        raise "wtF hax!!"  unless klass < self  # klass should be a descendant of us
        klass.new(*a, &b)
      else
        super
      end
    end
  end
end

ActiveRecord::Base.send :extend, ActiveRecord::StiInstantiation::ActMacro