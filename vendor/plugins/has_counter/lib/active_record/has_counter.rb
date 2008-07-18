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
        options.reverse_merge! :after_create  => :increment!, 
                               :after_destroy => :decrement!
        
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
        
          after_create do |forum|
            counter = Counter.create! :owner => forum, :name => name.to_s
          end
        
          # Wire up the counted class so that it updates our counter
          update = lambda{|record, event|
            owner = record.send(owner_name)
            if owner && counter = owner.send(counter_name)
              method = options[event]
              method = method.call(record) if Proc === method
              counter.send method if method
            end
          }          
          class_name.to_s.classify.constantize.class_eval do
            after_create do |record|
              update.call(record, :after_create)
            end
            after_save do |record|
              update.call(record, :after_save)
            end
            after_destroy do |record| 
              update.call(record, :after_destroy)
            end
          end
        end
      end
    end
  end
end

