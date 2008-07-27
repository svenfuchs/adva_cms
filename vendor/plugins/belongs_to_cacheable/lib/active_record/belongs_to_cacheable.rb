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
              cached_attributes(#{name.inspect}).each do |attribute|
                self[:"#{name}_\#{attribute}"] = #{name}.send attribute
              end
            end
            
            def cached_attributes(name)
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
          
            def #{name}_with_association_default(force_reload = false) 
              send :"#{name}_without_association_default" || 
              instantiate_from_cached_attributes(#{name.inspect})
            end
            alias_method_chain :#{name}, :association_default

            def is_#{name}?(object)
              self.#{name} == object
            end
          code
        end
        
        # def define_attribute_methods_with_belongs_to_cacheable
        #   define_attribute_methods_without_belongs_to_cacheable
        # end
        # alias_method_chain :define_attribute_methods, :belongs_to_cacheable
        
        # define_method :method_missing_with_belongs_to_cacheable do |name, *args|
        #   if !self.class.generated_methods?
        #     associations.each do |association|
        #       cached_attributes(association).each do |attribute|
        #         self.class.class_eval <<-code, __FILE__, __LINE__
        #           def #{association}_#{attribute}
        #             read_attribute(:#{association}_#{attribute}) || (#{association} ? #{association}.#{attribute} : nil)
        #           end
        #         code
        #       end
        #     end
        #   end          
        #   method_missing_without_belongs_to_cacheable(name, *args)
        # end        
        # alias_method_chain :method_missing, :belongs_to_cacheable
      end
    end
  end
end