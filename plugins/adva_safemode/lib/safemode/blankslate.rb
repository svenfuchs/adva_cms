module Safemode
  class Blankslate
    @@allow_instance_methods = ['class', 'inspect', 'methods', 'respond_to?', 'to_s', 'instance_variable_get']
    @@allow_class_methods    = ['methods', 'new', 'name', 'inspect', '<', 'ancestors', '==']
    # < needed in Rails Object#subclasses_of, ancestors and == is needed by rails/generate

    silently { undef_methods(*instance_methods - @@allow_instance_methods) }
    class << self
      silently { undef_methods(*instance_methods - @@allow_class_methods) }

      def method_added(name) end # ActiveSupport needs this
    end
  end
end
