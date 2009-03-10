module ActiveRecord
  module HasCounter
    class << self
      def included(base)
        base.extend ActMacro
      end
    end
    
    module ActMacro
      def has_counter(*names)
        options = names.extract_options!
        callbacks = options[:callbacks] || { :after_create  => :increment!, :after_destroy => :decrement! }

        class_inheritable_accessor :"update_counters"
        self.update_counters ||= {}
        
        names.each do |name|
          counter_name = :"#{name}_counter"
          owner_name = options[:as] || self.name.demodulize.underscore
          class_name = options[:class_name] || name

          define_method :"#{name}_count" do
            send(counter_name).count
          end
        
          has_one counter_name, :as => :owner, 
                                :class_name => 'Counter', 
                                :conditions => "name = '#{name}'",
                                :dependent => :delete
        
          # create the counter lazily upon first access
          class_eval <<-code, __FILE__, __LINE__
            def #{counter_name}_with_lazy_creation(force_reload = false) 
              result = #{counter_name}_without_lazy_creation(force_reload)
              if result.nil?
                Counter.create!(:owner => self, :name => #{name.to_s.inspect})
                result = #{counter_name}_without_lazy_creation(true)
              end
              result
            end
            alias_method_chain counter_name, :lazy_creation
          code

          # Wire up the counted class so that it updates our counter, basically
          # an anonymous callback/observer pattern
          target = class_name.to_s.classify.constantize
          callbacks.keys.each do |callback|
            target.send callback do |record|
              owner = record.send(owner_name) if record.respond_to?(owner_name)
              # do not update the counter when counter's owner (e.g. article) is not frozen (deleted)
              if self === owner && !owner.frozen? && record.class == target
                method = callbacks[callback]
                method = method.call(record) if Proc === method
                counter = owner.send(counter_name) if method
                counter.send method if counter && method
              end
            end
          end
        end
      end
    end
  end
end

