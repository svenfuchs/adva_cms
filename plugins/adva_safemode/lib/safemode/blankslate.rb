module Safemode
  class Blankslate
    @@allow_instance_methods = ['class', 'inspect', 'methods', 'respond_to?', 'to_s', 'instance_variable_get']
    @@allow_class_methods    = ['methods', 'new', 'name', 'inspect', '<', 'ancestors', '==']
    # < needed in Rails Object#subclasses_of, ancestors and == is needed by rails/generate

    silently { undef_methods(*instance_methods - @@allow_instance_methods) }
    class << self
      silently { undef_methods(*instance_methods - @@allow_class_methods) }

      def method_added(name) end # ActiveSupport needs this

      def inherited(subclass)
        subclass.init_allowed_methods(@allowed_methods)
      end

      def init_allowed_methods(allowed_methods)
        @allowed_methods = allowed_methods
      end

      def allowed_methods
        @allowed_methods ||= []
      end

      def allow(*names)
        @allowed_methods = alter_allowed_method_list(names, :+)
      end

      def disallow(*names)
        @allowed_methods = alter_allowed_method_list(names, :-)
      end

      def allowed?(name)
        allowed_methods.include? name.to_s
      end

      private

      def alter_allowed_method_list(names, alter_method = :+)
        am = allowed_methods.send(alter_method, names.map{|name| name.to_s}).uniq
      end
    end
  end
end
