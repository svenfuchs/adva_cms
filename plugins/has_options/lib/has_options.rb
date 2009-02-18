# TODO allow a :type option and typecast the value

module HasOptions
  class << self
    def included(base)
      base.class_eval do
        extend ClassMethods
        class_inheritable_accessor :option_definitions
        self.option_definitions = {}
        serialize :options
      end
    end

    module ClassMethods
      def has_option(*names)
        definition = names.extract_options!
        names.each do |name|
          self.option_definitions[name] = definition.reverse_update(:default => nil, :type => :text_field)
          class_eval <<-src, __FILE__, __LINE__
            def #{name}
              #{name}_before_type_cast
            end

            def #{name}_before_type_cast
              self.options ||= {}
              options[:#{name}] || option_definitions[:#{name}][:default]
            end

            def #{name}=(value)
              options_will_change!
              self.options ||= {}
              options[:#{name}] = value
            end
          src
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, HasOptions