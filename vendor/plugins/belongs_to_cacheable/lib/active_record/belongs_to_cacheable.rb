module ActiveRecord
  module BelongsToCacheable
    def self.included(base)
      base.extend ActMacro  
    end

    module ActMacro
      def belongs_to_cacheable(*args)
        options = args.extract_options!
        options.reverse_merge! :validate => true
        validate = options.delete :validate # TODO make this more flexible
        
        args.each do |assocication|
          HelperMethods.define_methods self, assocication, validate
        end
      end
    end
    
    module HelperMethods
      class << self
        def cached_attributes(target, name)
          target.column_names.map do |attribute| 
            attribute =~ /^#{name}_(.*)/ && !['id', 'type'].include?($1) ? $1 : nil            
          end.compact
        end
        
        def define_methods(target, name, validate)
          attributes = cached_attributes(target, name)
          
          cache_attributes_code = attributes.map do |attribute|
            "self[:#{name}_#{attribute}] = #{name}.#{attribute}"
          end.join("\n")
        
          target.class_eval <<-code, __FILE__, __LINE__
            belongs_to :#{name}, :polymorphic => true # TODO :with_deleted => true
            if #{validate.inspect}
              validates_presence_of :#{name}
              validates_associated  :#{name}
            end
            before_save :cache_#{name}_attributes!
            
            def #{name}_with_association_default(force_reload = false) 
              #{name}_without_association_default || 
              instantiate_from_cached_attributes(#{name.inspect}, #{attributes.inspect})
            end
            alias_method_chain :#{name}, :association_default

            def is_#{name}?(object)
              self.#{name} == object
            end

            protected
              def cache_#{name}_attributes!
                return unless #{name}
                #{cache_attributes_code}
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
          
          attributes.each do |attribute|
            target.class_eval <<-code, __FILE__, __LINE__
              def #{name}_#{attribute}
                read_attribute(:#{name}_#{attribute}) || (#{name} ? #{name}.#{attribute} : nil)
              end
            code
          end
        end
      end
    end
  end
end