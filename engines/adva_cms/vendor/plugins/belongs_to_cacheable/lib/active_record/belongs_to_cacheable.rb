module ActiveRecord
  module BelongsToCacheable
    def self.included(base)
      base.extend ActMacro
    end

    module ActMacro
      def belongs_to_cacheable(*args)
        options = args.extract_options!
        options.reverse_merge! :validate => true  # FIXME Content.author should not be polymorphic
        validate = options.delete :validate # TODO make this more flexible
        associations = args

        associations.each do |name|
          belongs_to name, :polymorphic => true
          if validate
            validates_presence_of name
            validates_associated  name
          end
          before_save :"cache_#{name}_attributes!"

          class_eval <<-code, __FILE__, __LINE__
            def cache_#{name}_attributes!
              return unless #{name}
              cached_attributes_for(#{name.inspect}).each do |attribute|
                self[:"#{name}_\#{attribute}"] = #{name}.send attribute
              end
            end

            def #{name}_with_default_instance
              send :"#{name}_without_default_instance" ||
              instantiate_from_cached_attributes(#{name.inspect})
            end
            alias_method_chain :#{name}, :default_instance

            def is_#{name}?(object)
              self.#{name} == object
            end

            class << self
              def define_attribute_methods_with_cached_#{name}
                define_attribute_methods_without_cached_#{name}
                cached_attributes_for(#{name.inspect}).each do |attribute|
                 define_method :"#{name}_\#{attribute}" do
                   read_attribute(:"#{name}_\#{attribute}") || (#{name} ? #{name}.send(attribute) : nil)
                 end
                end
              end
              alias_method_chain :define_attribute_methods, :cached_#{name}
            end
          code
        end

        (class << self; self; end).class_eval <<-code, __FILE__, __LINE__
          def cached_attributes_for(name)
            column_names.map do |attribute|
              attribute.to_s =~ /^\#{name}_(.*)/ && !['id', 'type'].include?($1) ? $1 : nil
            end.compact
          end
        code

        class_eval <<-code, __FILE__, __LINE__
          def cached_attributes_for(name)
            attributes.keys.map do |attribute|
              attribute.to_s =~ /^\#{name}_(.*)/ && !['id', 'type'].include?($1) ? $1 : nil
            end.compact
          end

          def instantiate_from_cached_attributes(name, attributes)
            if type = respond_to?(:"\#{name}_type") ? send(:"\#{name}_type") : name.classify
              returning type.constantize.new do |object|
                attributes.each do |attribute|
                  object.send :"\#{attribute}=", send(:"\#{name}_\#{attribute}")
                end
              end
            end
          end
        code
      end
    end
  end
end