# http://coderrr.wordpress.com/2008/04/22/building-the-right-class-with-sti-in-rails/

module ActiveRecord::StiInstantiation
  def instantiates_with_sti
    extend ClassMethods
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

ActiveRecord::Base.send :extend, ActiveRecord::StiInstantiation